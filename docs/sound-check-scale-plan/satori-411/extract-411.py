import re,json,pathlib,base64,hashlib,collections,struct,os
root=pathlib.Path(__file__).resolve().parent;html=pathlib.Path(os.environ.get('ORIGINAL_LAB', '/workspace/beast-sound-check/original-lab/sound-check.html')).read_bytes();d=json.loads(re.search(rb'<script[^>]*id="data"[^>]*>(.*?)</script>',html,re.S).group(1));t=next(t for t in d['tracks'] if t['id']=='411');settings=t['d'].split('</script>',1)[0];midi=base64.b64decode(re.search(r'id="midi">(.*?)</script>',t['d'],re.S).group(1));(root/'track-411.settings.txt').write_text(settings);(root/'track-411.mid').write_bytes(midi)
assert len(midi)==t['midiBytes'] and len(settings)==t['settingsBytes']
p=14;tracks=[];events=[]
def vlq(b,i):
 n=0
 while True:
  c=b[i];i+=1;n=(n<<7)|(c&127)
  if c<128:return n,i
for tr in range(int.from_bytes(midi[10:12],'big')):
 assert midi[p:p+4]==b'MTrk';l=int.from_bytes(midi[p+4:p+8],'big');b=midi[p+8:p+8+l];p+=8+l;i=0;time=0;running=None;te=[]
 while i<len(b):
  delta,i=vlq(b,i);time+=delta;s=b[i]
  if s>=128:i+=1;running=s
  else:s=running
  if s==255:
   k=b[i];i+=1;n,i=vlq(b,i);v=list(b[i:i+n]);i+=n;e=dict(track=tr,tick=time,type='meta',kind=k,data=v)
  elif s in [240,247]:
   n,i=vlq(b,i);v=list(b[i:i+n]);i+=n;e=dict(track=tr,tick=time,type='sysex',data=v)
  else:
   k=s>>4;n=1 if k in [12,13] else 2;v=list(b[i:i+n]);i+=n;e=dict(track=tr,tick=time,channel=s&15,type={8:'off',9:'on',11:'cc',12:'program',14:'bend'}.get(k,str(k)),data=v)
  te.append(e);events.append(e)
 tracks.append(dict(index=tr,end_tick=time,event_count=len(te)))
ch={}
for c in sorted(set(e['channel'] for e in events if 'channel'in e)):
 es=[e for e in events if e.get('channel')==c];ons=[e for e in es if e['type']=='on' and e['data'][1]>0];offs=[e for e in es if e['type']=='off'];ch[str(c)]=dict(programs=[e['data'][0] for e in es if e['type']=='program'],controllers=[dict(tick=e['tick'],controller=e['data'][0],value=e['data'][1]) for e in es if e['type']=='cc'],notes=len(ons),pitches=sorted(set(e['data'][0] for e in ons)),velocities=sorted(set(e['data'][1] for e in ons)),first_on=min(e['tick'] for e in ons),last_on=max(e['tick'] for e in ons),last_off=max([e['tick'] for e in offs],default=None))
summary=dict(source_html_sha256=hashlib.sha256(html).hexdigest(),midi_sha256=hashlib.sha256(midi).hexdigest(),settings_sha256=hashlib.sha256(settings.encode()).hexdigest(),midi_bytes=len(midi),settings_bytes=len(settings),format=int.from_bytes(midi[8:10],'big'),ppq=int.from_bytes(midi[12:14],'big'),tracks=tracks,channels=ch,tempo=[e for e in events if e['type']=='meta' and e['kind']==81],pitch_bends=sum(e['type']=='bend' for e in events),all_note_ons=sum(v['notes'] for v in ch.values()))
(root/'track-411.events.json').write_text(json.dumps(events,indent=2));(root/'track-411.analysis.json').write_text(json.dumps(summary,indent=2));print(json.dumps(summary,indent=2))
