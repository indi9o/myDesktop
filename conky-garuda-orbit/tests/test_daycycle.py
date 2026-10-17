import importlib.util
from pathlib import Path
import unittest
from datetime import datetime
from zoneinfo import ZoneInfo

spec = importlib.util.spec_from_file_location('daycycle_curve', Path(__file__).resolve().parents[1]/'theme/daycycle.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
cycle = module.cycle
ZONE = ZoneInfo('Asia/Jakarta')


def epoch(value):
    return datetime.fromisoformat(value).replace(tzinfo=ZONE).timestamp()


class DayCurveTests(unittest.TestCase):
    def setUp(self):
        self.days = [dict(sunrise=epoch(f'2026-10-{d}T05:30'), sunset=epoch(f'2026-10-{d}T17:30')) for d in [16,17,18]]

    def test_noon_and_midnight_are_on_opposite_sides_of_horizon(self):
        noon=cycle(epoch('2026-10-17T11:30'),self.days)
        night=cycle(epoch('2026-10-17T23:30'),self.days)
        self.assertEqual(noon['solar_phase'],'day')
        self.assertAlmostEqual(float(noon['curve_now']),1)
        self.assertAlmostEqual(float(night['curve_now']),-.4)
        self.assertEqual(night['solar_phase'],'night')

    def test_axis_is_local_24_hour_clock_not_phase_progress(self):
        for hour in [0,6,12,18,23]:
            d=cycle(epoch(f'2026-10-17T{hour:02}:00'),self.days)
            self.assertAlmostEqual(float(d['clock_progress']),hour/24)
            self.assertEqual(len(d['curve_points'].split(',')),97)
        # Midnight wraps x, but the curve's vertical position remains continuous.
        points=list(map(float,d['curve_points'].split(',')))
        self.assertAlmostEqual(points[0],points[-1])

    def test_today_labels_do_not_switch_to_tomorrow_at_sunset(self):
        self.days[2]['sunrise']=epoch('2026-10-18T05:31')
        for hour in [0,12,23]:
            d=cycle(epoch(f'2026-10-17T{hour:02}:00'),self.days)
            self.assertEqual(d['sunrise_label'],'05.30')
            self.assertEqual(d['sunset_label'],'17.30')
            self.assertEqual(d['solar_source'],'open-meteo')

    def test_exact_rise_and_set_cross_horizon_without_resetting_x(self):
        for stamp,phase in [('2026-10-17T05:30','day'),('2026-10-17T17:30','night')]:
            d=cycle(epoch(stamp),self.days)
            self.assertEqual(d['solar_phase'],phase)
            self.assertAlmostEqual(float(d['curve_now']),0)
            self.assertGreater(float(d['clock_progress']),0)
            before=cycle(epoch(stamp)-.1,self.days)
            self.assertAlmostEqual(float(before['curve_now']),0,places=4)

    def test_missing_bad_or_expired_cache_is_marked_as_estimate(self):
        for days in [None,{},[None,{},dict(sunrise=float('nan'),sunset=42)],[],self.days]:
            d=cycle(epoch('2026-10-24T12:00'),days)
            self.assertEqual(d['solar_source'],'estimated')
            self.assertEqual(d['sunrise_label'],'06.00')
            self.assertEqual(d['sunset_label'],'18.00')
            self.assertAlmostEqual(float(d['curve_now']),1)


if __name__=='__main__':
    unittest.main()
