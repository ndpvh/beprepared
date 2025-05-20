import warnings
import random
import ipdb

from corona_model.actions import *
from corona_model.facing import Facing
from corona_model.surfaces import Fixture


class Agent:
    class_counter = 0

    def __init__(self, name, viral_load, contamination_load_air, contamination_load_droplet, contamination_load_surface,
                 emission_rate_air, emission_rate_droplet, pick_up_air, pick_up_droplet,
                 script, is_active=False, wearing_mask=False):
        self.id = Agent.class_counter
        self.name = name
        self.viral_load = viral_load
        self.contamination_load_air = contamination_load_air  
        self.contamination_load_droplet = contamination_load_droplet
        self.contamination_load_surface_accumulation = contamination_load_surface  # Set initial surface contamination load
        self.emission_rate_air = emission_rate_air
        self.emission_rate_droplet = emission_rate_droplet
        self.pick_up_air = pick_up_air
        self.pick_up_droplet = pick_up_droplet
        self.script = script
        first_action = None
        if not script:
            warnings.warn('Agent {} has no script'.format(name))
        else:  # Check first action
            first_action = script[min(script.keys())]
            if not isinstance(first_action, Enter):
                warnings.warn('First script action is not Enter, Agent {} will never be active'.format(name))
        self.is_active = is_active
        self.held = list()  # Keeps track of held Items
        self.effects = list()  # Effects that the Agent is under (e.g. Handwash)
        if first_action:
            self.facing: Facing = Facing(first_action.facing) if isinstance(first_action, Enter) else Facing.NORTH
        else:  # Set facing to North even though Agent will do nothing
            self.facing = Facing.NORTH
        if wearing_mask:
            self.don_mask()
        self.queued_cough = False
        Agent.class_counter += 1
    
        self.config = None

    def set_config(self, config):
        self.config = config

        # ipdb.set_trace()
        if self.viral_load > 0:
            def maybe_cough():
                if (random.random() <
                        config['env']['CoughingRate'] *
                        config['env']['SimulationTimeStep']):
                    self.queued_cough = True
            self.effects.append(Effect('coughing', event=maybe_cough))

    def emit_aerosol(self):
        emission_load = (self.viral_load * self.emission_rate_air *
                         self.config['env']['SimulationTimeStep'])
        if self.queued_cough:
            emission_load = (self.viral_load * self.emission_rate_air *
                             self.config['env']['SimulationTimeStep'] *
                             self.config['env']['CoughingFactor'] *
                             self.config['env']['CoughingAerosolPercentage'])
        if self.under_effect('wearing_mask'):
            return emission_load * self.config['env']['MaskEmissionAerosolReductionEfficiency']
        else:
            return emission_load

    def emit_droplet(self):
        emission_load = (self.viral_load * self.emission_rate_droplet *
                         self.config['env']['SimulationTimeStep'])
        if self.queued_cough:
            emission_load = (self.viral_load * self.emission_rate_air *
                             self.config['env']['SimulationTimeStep'] *
                             self.config['env']['CoughingFactor'] *
                             self.config['env']['CoughingDropletPercentage'])
        if self.under_effect('wearing_mask'):
            return emission_load * self.config['env']['MaskEmissionDropletReductionEfficiency']
        else:
            return emission_load

    def pickup_air(self, air_load, pick_up_air):
        if self.under_effect('wearing_mask'):
            self.contamination_load_air = air_load * pick_up_air * \
                                          self.config['env']['SimulationTimeStep'] * \
                                          self.config['env']['MaskAerosolProtectionEfficiency']
        else:  # Could also be the case that masks can not protect people from aerosol. then delete masks' impact in pickup_air
            self.contamination_load_air = air_load * pick_up_air * self.config['env']['SimulationTimeStep']

    def pickup_droplet(self, droplet_load, pick_up_droplet):
        if self.under_effect('wearing_mask'):
           self.contamination_load_droplet = droplet_load * pick_up_droplet * \
                                             self.config['env']['SimulationTimeStep'] * \
                                             self.config['env']['MaskDropletProtectionEfficiency']
        else:
            self.contamination_load_droplet = droplet_load * pick_up_droplet * \
                                              self.config['env']['SimulationTimeStep']

    def pickup_from_surface(self, surface):
        if self.under_effect('handwash'):  # Check for handwash effect
            return  # No pickup from surfaces if under handwash effect

        # Compute transferred load for this tick
        if isinstance(surface, Fixture):  # Rate based pickup
            transferred_load = surface.contamination_load * surface.transfer_rate * \
                               self.config['env']['SimulationTimeStep']
        else:  # Ratio based pickup, dt not needed
            transferred_load = surface.contamination_load * surface.transfer_rate
        # Sum contamination load to Agent(self)
        self.contamination_load_surface_accumulation += transferred_load
        # Remove what Agent took from surface
        surface.contamination_load -= transferred_load

    def hand_to_surface_transfer(self, surface):
        if isinstance(surface, Fixture):
            transferred_load = self.contamination_load_surface_accumulation * surface.transfer_rate * \
                               self.config['env']['SimulationTimeStep']
        else:
            transferred_load = self.contamination_load_surface_accumulation * surface.transfer_rate
        surface.contamination_load += transferred_load

    def hold(self, item):
        """Adds Item to held list if not already in list
        Pickup contamination load from Item"""
        if item not in self.held:
            self.held.append(item)
            self.pickup_from_surface(item)
            self.hand_to_surface_transfer(item)
        else:
            warnings.warn("{} is already holding {}".format(self, item))

    def release(self, item):
        """Removes Item from held list if in list"""
        if item in self.held:
            self.held.remove(item)
        else:
            warnings.warn("{} is not holding {} so it can not be release".format(self, item))

    def start_handwash_effect(self):
        # Check for and get existing handwash effect
        for effect in self.effects:
            if effect.name == 'handwash':
                effect.remaining_ticks = (self.config['env']['HandwashingEffectDuration'] /
                                          self.config['env']['SimulationTimeStep'])  # Reset effect duration
                return  # Do not add another

        # No existing handwash effect found so start a new one
        end_handwashing_effect_contamination_load = self.contamination_load_surface_accumulation

        def end_handwashing_effect():
            self.contamination_load_surface_accumulation = end_handwashing_effect_contamination_load

        duration = (self.config['env']['HandwashingEffectDuration'] /
                    self.config['env']['SimulationtimeStep'])
        e = Effect('handwash', duration=duration, conclusion=end_handwashing_effect)
        self.contamination_load_surface_accumulation = (self.contamination_load_surface_accumulation *
                                                        self.config['env']['HandwashingContaminationFraction'])
        self.effects.append(e)

    def don_mask(self):
        if not self.under_effect('wearing_mask'):
            e = Effect('wearing_mask')
            self.effects.append(e)

    def doff_mask(self):
        for effect in self.effects:
            if effect.name == 'wearing_mask':
                self.effects.remove(effect)

    def process_effects(self):
        for effect in self.effects:
            effect.tick()
            if effect.remaining_ticks == 0:
                self.effects.remove(effect)

    def under_effect(self, name):
        """Check if given effect name is in effect list"""
        for effect in self.effects:
            if effect.name == name:
                return True
        return False

    def set_facing(self, direction: str):
        self.facing = Facing(direction)

    def __hash__(self):
        return self.id

    def __repr__(self):
        return self.name

    def serialize(self):
        return {
            'name': self.name,
            'viral_load': self.viral_load,
            'contamination_load_air': self.contamination_load_air,
            'contamination_load_droplet': self.contamination_load_droplet,
            'contamination_load_surface': self.contamination_load_surface_accumulation,
            'emission_rate_air': self.emission_rate_air,
            'emission_rate_droplet': self.emission_rate_droplet,
            'pick_up_air': self.pick_up_air,
            'pick_up_droplet': self.pick_up_droplet,
            'script': {k: a.serialize() for k, a in self.script.items()},
            'is_active': self.is_active,
            'wearing_mask': self.under_effect('wearing_mask'),
        }

    @classmethod
    def deserialize(cls, serial):
        # Create a new dictionary where the keys will be integers
        # rather than strings, thus matching their original
        # definition.
        script = dict()
        for k, a in serial['script'].items():
            if a['type'] == 'move':
                script[int(k)] = Move.deserialize(a)
            elif a['type'] == 'leave':
                script[int(k)] = Leave.deserialize()
            elif a['type'] == 'pickup':
                script[int(k)] = Pickup.deserialize(a)
            elif a['type'] == 'putdown':
                script[int(k)] = Putdown.deserialize(a)
            elif a['type'] == 'enter':
                script[int(k)] = Enter.deserialize(a)
            elif a['type'] == 'handwash':
                script[int(k)] = Handwash.deserialize()
            elif a['type'] == 'donmask':
                script[int(k)] = DonMask.deserialize()
            elif a['type'] == 'doffmask':
                script[int(k)] = DoffMask.deserialize()
            elif a['type'] == 'face':
                script[int(k)] = Face.deserialize(a)
        serial['script'] = script
        if 'contamination_fraction' in serial:
            serial.pop('contamination_fraction')
        return Agent(**serial)


class Effect:
    def __init__(self, name, duration=None, event=None, conclusion=None):
        self.name = name  # type of effect
        self.remaining_ticks = duration
        self.event = event
        self.conclusion = conclusion

    def tick(self):
        if self.event:
            self.event()
        if self.remaining_ticks is not None:
            self.remaining_ticks = self.remaining_ticks - 1
        if self.remaining_ticks == 0:
            if self.conclusion:
                self.conclusion()  # conclusion happens on same tick as last event

