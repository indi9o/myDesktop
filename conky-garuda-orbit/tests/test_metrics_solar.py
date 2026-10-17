import sys,tempfile,importlib.util,json,unittest
from pathlib import Path
from unittest.mock import patch
from io import BytesIO
THEME=Path(__file__).resolve().parents[1]/'theme'
sys.path.insert(0,str(THEME))
class StopRefresh(Exception): pass
class SolarCollectorTests(unittest.TestCase):
 def test_refresh_cache_and_offline_estimate(self):
  with tempfile.TemporaryDirectory() as t, patch('pathlib.Path.home',return_value=Path(t)):
   spec=importlib.util.spec_from_file_location('garuda_metrics',THEME/'metrics.py')
   m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
   data={'current':{'temperature_2m':24,'weather_code':2},'daily':{'sunrise':[1792188000,1792274400,1792360800],'sunset':[1792231200,1792317600,1792404000]}}
   with patch.object(m.urllib.request,'urlopen',return_value=BytesIO(json.dumps(data).encode())) as http,patch.object(m.time,'sleep',side_effect=StopRefresh):
    try:m.refresh_weather()
    except StopRefresh:pass
    assert 'daily=sunrise,sunset' in http.call_args.args[0]
    assert 'past_days=1' in http.call_args.args[0]
   assert len(m.weather['solar_days'])==3
   with patch.object(m.time,'time',return_value=1792296000):
    assert m.collect()['solar_source']=='open-meteo'
   m.weather['solar_days']=[]
   assert m.collect()['solar_source']=='estimated'
   assert 'solar_days' not in m.collect()


if __name__=='__main__': unittest.main()
