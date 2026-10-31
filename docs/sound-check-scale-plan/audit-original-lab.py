#!/usr/bin/env python3
"""Read-only audit of the user's original sampler Git objects; no music implementation."""
import base64, hashlib, json, re, subprocess, os
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = Path(os.environ.get('SAMPLER', '/workspace/beast-sound-check'))

def decode_smf(data):
    ppq = int.from_bytes(data[12:14], 'big')
    at, notes, programs, controls, tempos, ends = 14, [], [], [], [], []
    while at < len(data):
        assert data[at:at+4] == b'MTrk'
        end = at + 8 + int.from_bytes(data[at+4:at+8], 'big')
        at += 8
        time, running, ons = 0, None, {}
        def vlq():
            nonlocal at
            n = 0
            while True:
                x = data[at]; at += 1; n = 128*n+(x&127)
                if x < 128: return n
        while at < end:
            time += vlq()
            if data[at] >= 128:
                status = data[at]; at += 1
                if status < 240: running = status
            else:
                assert running is not None
                status = running
            if status == 255:
                kind = data[at]; at += 1; n = vlq(); payload = data[at:at+n]; at += n
                if kind == 81: tempos.append({'tick':time,'tempo_us':int.from_bytes(payload,'big')})
                if kind == 47: ends.append(time)
            elif status in (240,247):
                n = vlq(); at += n
            else:
                kind,ch = status&240,status&15
                size = 1 if kind in (192,208) else 2
                vals = data[at:at+size]; at += size
                if kind == 192: programs.append({'tick':time,'channel':ch,'program':vals[0]})
                if kind == 176: controls.append({'tick':time,'channel':ch,'cc':vals[0],'value':vals[1]})
                if kind == 144 and vals[1] > 0:
                    ons[(ch,vals[0])] = (time,vals[1])
                elif kind == 128 or kind == 144:
                    start,vel=ons.pop((ch,vals[0])); notes.append({'tick':start,'duration':time-start,'pitch':vals[0],'velocity':vel,'channel':ch})
        assert not ons
    return {'ppq':ppq,'notes':sorted(notes,key=lambda n:(n['tick'],n['channel'])),'programs':programs,'controls':controls,'tempos':tempos,'end_tick':max(ends)}

def snapshot(commit):
    raw = subprocess.check_output(['git','-C',str(REPO),'show',commit+':index.html'])
    obj = json.loads(re.search(rb'<script[^>]*id=["\']data["\'][^>]*>(.*?)</script>',raw,re.S).group(1))
    records = []
    for track in obj['tracks']:
        if track['sectionId'] != '2' and track['id'] != '406': continue
        frag = ' '.join(v for v in track.values() if isinstance(v,str))
        midi = base64.b64decode(re.search(r'id="midi">(.*?)</script>',frag,re.S).group(1).strip())
        trace=decode_smf(midi)
        rec={'id':track['id'],'title':track['title'],'blurb':track['blurb'],'midi_sha256':hashlib.sha256(midi).hexdigest(),'midi_bytes':len(midi),'ppq':trace['ppq'],'programs':trace['programs'],'tempo_us':trace['tempos'][0]['tempo_us'],'note_count':len(trace['notes']),'min_pitch':min(n['pitch'] for n in trace['notes']),'max_pitch':max(n['pitch'] for n in trace['notes']),'end_tick':trace['end_tick']}
        if track['id'] in ['201','406']: rec['trace']=trace
        records.append(rec)
    return {'commit':subprocess.check_output(['git','-C',str(REPO),'rev-parse',commit],text=True).strip(),'index_html_sha256':hashlib.sha256(raw).hexdigest(),'page_version':obj['meta']['pageVersion'],'generated':obj['meta']['generated'],'records':records}

shots=[snapshot('439b264'),snapshot('433f826')]
(HERE/'original-presets.json').write_text(json.dumps({'schema':'sound-check-reference-audit/v1','source_repository':'https://github.com/Provable-Games/beast-sound-check','snapshots':shots},indent=2)+'\n')
for shot in shots:
    tracks=[t for t in shot['records'] if t['id']!='406']
    assert len(tracks)==20
    assert {t['note_count'] for t in tracks}=={49}
    assert {t['end_tick'] for t in tracks}=={15360}
    print(shot['commit'][:7], '20 presets, 49 notes each, 15360 ticks;',[(t['id'],t['programs'][0]['program'],t['tempo_us']) for t in tracks])
print('Wrote',HERE/'original-presets.json')
