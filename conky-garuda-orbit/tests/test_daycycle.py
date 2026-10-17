import importlib.util
import math
from pathlib import Path
import unittest
from datetime import datetime
from zoneinfo import ZoneInfo

spec = importlib.util.spec_from_file_location('daycycle', Path(__file__).resolve().parents[1]/'theme/daycycle.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
cycle = module.cycle
ZONE = ZoneInfo('Asia/Jakarta')


def epoch(value):
    return datetime.fromisoformat(value).replace(tzinfo=ZONE).timestamp()


class DayCycleTests(unittest.TestCase):
    def setUp(self):
        self.days = [dict(sunrise=epoch(f'2026-10-{d}T05:30'), sunset=epoch(f'2026-10-{d}T17:30')) for d in [16,17,18]]

    def test_daytime_and_opposite_icons(self):
        d=cycle(epoch('2026-10-17T11:30'),self.days)
        self.assertEqual(d['solar_phase'],'day')
        self.assertEqual(d['solar_source'],'open-meteo')
        self.assertAlmostEqual(float(d['solar_progress']),.5)
        self.assertAlmostEqual(float(d['sun_angle']),1.5*math.pi,places=6)
        self.assertAlmostEqual(float(d['moon_angle']),.5*math.pi,places=6)
        self.assertEqual(d['sunrise_label'],'05.30')

    def test_night_crosses_local_midnight(self):
        for stamp,progress in [('2026-10-17T23:30',.5),('2026-10-18T02:30',.75)]:
            d=cycle(epoch(stamp),self.days)
            self.assertEqual(d['solar_phase'],'night')
            self.assertAlmostEqual(float(d['solar_progress']),progress)
            self.assertEqual(d['solar_source'],'open-meteo')

    def test_exact_rise_and_set_switch_phase(self):
        for stamp,phase in [('2026-10-17T05:30','day'),('2026-10-17T17:30','night')]:
            d=cycle(epoch(stamp),self.days)
            self.assertEqual(d['solar_phase'],phase)
            self.assertEqual(float(d['solar_progress']),0)

    def test_uncovered_date_uses_marked_estimate(self):
        d=cycle(epoch('2026-10-24T12:00'),self.days)
        self.assertEqual(d['solar_source'],'estimated')
        self.assertEqual(d['sunrise_label'],'06.00')
        self.assertEqual(d['sunset_label'],'18.00')
        self.assertEqual(d['solar_phase'],'day')

    def test_bad_cache_and_offline_midnight(self):
        for days in [None,{},[None,{},dict(sunrise=float('nan'),sunset=42)],[]]:
            d=cycle(epoch('2026-10-17T00:00'),days)
            self.assertEqual(d['solar_phase'],'night')
            self.assertEqual(d['solar_source'],'estimated')
            self.assertAlmostEqual(float(d['solar_progress']),.5)

    def test_path_is_continuous_at_sunrise(self):
        before=cycle(epoch('2026-10-17T05:30')-.1,self.days)
        after=cycle(epoch('2026-10-17T05:30'),self.days)
        self.assertAlmostEqual(float(before['sun_angle']),float(after['sun_angle']),places=4)


if __name__=='__main__':
    unittest.main()
