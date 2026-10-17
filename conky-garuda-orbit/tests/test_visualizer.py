"""Signal-processing and placement regression tests; no sound server required."""
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
import numpy as np

spec = importlib.util.spec_from_file_location('visualizer', Path(__file__).resolve().parents[1]/'theme/visualizer.py')
v = importlib.util.module_from_spec(spec)
spec.loader.exec_module(v)


class SpectrumTests(unittest.TestCase):
    def test_tone_occupies_expected_frequency_band_and_hides_after_silence(self):
        s = v.Spectrum()
        tone = (.18*np.sin(2*np.pi*1000*np.arange(v.SIZE)/v.RATE)*32767).astype('<i2').tobytes()
        active, levels = s.update(tone, 10)
        self.assertTrue(active)
        peak = int(np.argmax(levels))
        self.assertLess(s.edges[peak], 1150)
        self.assertGreater(s.edges[peak+1], 850)
        silent = bytes(v.SIZE*2)
        self.assertTrue(s.update(silent, 12.9)[0])
        self.assertFalse(s.update(silent, 13.1)[0])
        self.assertTrue(s.update(tone, 14)[0])

    def test_silence_never_activates_and_output_is_bounded(self):
        s = v.Spectrum()
        self.assertFalse(s.update(bytes(v.SIZE*2), 5)[0])
        raw = np.full(v.SIZE, 32767, dtype='<i2').tobytes()
        for i in range(20):
            _, levels = s.update(raw, i)
            self.assertTrue(np.all((levels >= 0) & (levels <= 1)))

    def test_missing_source_is_not_replaced_with_microphone(self):
        with patch.object(v.subprocess, 'check_output', side_effect=OSError):
            self.assertIsNone(v.default_monitor())
        with patch.object(v.subprocess, 'check_output', return_value='headset\n'):
            self.assertEqual(v.default_monitor(), 'headset.monitor')

    def test_dragged_position_persists_and_stays_within_screen(self):
        with tempfile.TemporaryDirectory() as d, patch.object(v, 'SETTINGS', Path(d)/'position.json'):
            v.atomic(v.SETTINGS, json.dumps({'x': 720, 'y': 800}))
            self.assertEqual(v.position()['x'], 720)
            with patch.object(v, 'screen', return_value=(1366, 768, 0, 0)):
                x,y,w,h,scale=v.geometry()
                self.assertLessEqual(x+w, 1366)
                self.assertLessEqual(y+h, 768)
            v.atomic(v.SETTINGS, '{broken')
            self.assertEqual(v.position(), v.DEFAULT)
            v.atomic(v.SETTINGS, json.dumps({'x': 1e9, 'y': -10}))
            self.assertEqual(v.position()['x'], 790)
            self.assertEqual(v.position()['y'], 0)


if __name__ == '__main__':
    unittest.main()
