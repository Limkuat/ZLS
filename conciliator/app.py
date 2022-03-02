import json
import os
import subprocess
from datetime import datetime, timedelta

import humanize
import pytz
from flask import Flask, request, Response, abort
from pymediainfo import MediaInfo
from pymkv import MKVFile, MKVTrack

app = Flask(__name__, static_url_path='/segs/', static_folder='segs/')

UPLOAD_FOLDER = "./segs/"

FILES = []

tz = pytz.timezone("Europe/Paris")


@app.route("/")
def hello_world():  # put application's code here
    return "Hello World!"


@app.route("/hls/master.m3u8")
def hls_playlist_master():
    return """#EXTM3U
#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="audio",LANGUAGE="eng",NAME="English",AUTOSELECT=YES, DEFAULT=YES,URI="audio.m3u8"

#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=195023,CODECS="avc1.42e00a,mp4a.40.2",AUDIO="audio"
video.m3u8
    """


@app.route("/hls/<type>.m3u8")
def hls_source_playlist(type: str):
    if type not in ('audio', 'video'):
        abort(404)

    ext = 'mkv' if type == 'video' else 'mka'

    m3u8_files = ""
    media_seq = None

    for seg, time, duration in FILES[-30:-10]:
        if not seg.endswith(ext):
            continue
        if media_seq is None:
            media_seq = seg.split('.')[0]
        m3u8_files += f"#EXT-X-PROGRAM-DATE-TIME:{time.isoformat()}\n"
        m3u8_files += f"#EXTINF:{duration},live\n"
        m3u8_files += f"/segs/{seg}\n"

    m3u8 = "#EXTM3U\n"
    m3u8 += "#EXT-X-VERSION:3\n"
    m3u8 += "#EXT-X-TARGETDURATION:3\n"
    m3u8 += "#EXT-X-START:TIME-OFFSET=0\n"
    m3u8 += f"#EXT-X-MEDIA-SEQUENCE:{media_seq or 0}\n"
    m3u8 += m3u8_files

    return Response(m3u8, content_type="text/plain")


@app.route("/ingest/<seg_id>", methods=["POST"])
def upload_file(seg_id: str):
    raw_content = request.get_data()
    if not raw_content:
        abort(400)

    name = os.path.join("segs", seg_id)

    with open(name, "wb") as f:
        f.write(raw_content)

    mediainfo_process = subprocess.Popen(
        ["mediainfo", name, "--Output=JSON"],
        stdout=subprocess.PIPE,
        stdin=subprocess.PIPE,
    )
    stdout, stderr = mediainfo_process.communicate()

    mediainfo = json.loads(stdout)

    # print()
    # print(f'----- {mediainfo["media"]["@ref"]} -----')
    # print(json.dumps(mediainfo))

    for i, track in enumerate(mediainfo['media']['track']):
        # print(f'TRACK {i}')
        # print('⋅', track.get('FrameRate', 'N/A'), 'FPS -', track.get('FrameCount', 'N/A'), 'frames')
        # print(f'⋅ Duration: {track.get("Duration", "N/A")}s')

        if "extra" in track:
            # print('⋅ Extra')
            # for k, v in track['extra'].items():
            #     print(f'  - {k} : {v}')
            # print()

            start_time = datetime.fromtimestamp(int(track['extra']['ORG_MYOPENBACKBACK_START']) / 1000)
            start_time = tz.localize(start_time, is_dst=None)

            # print(t.isoformat(), '(video)' if seg_id.endswith('mkv') else '(audio)', humanize.precisedelta(datetime.now() - t))

        else:
            duration = track.get("Duration")

    absolute_time = start_time + timedelta(seconds=float(duration) * int(seg_id.split('.')[0]))

    FILES.append((seg_id, absolute_time.astimezone(pytz.utc), duration))

    #     print()
    #
    # print()

    return Response(status=201)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=65535, debug=True)
