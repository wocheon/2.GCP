# Slack API - Cloud Function

## 개요 
- 기존 docker image를 통해 컨테이너를 실행하는 형식이 아닌 GCP Cloud Funtion으로 등록하여 Slack API를 호출하는 방식

- 엑세스 제어를 통해 특정 유저만 호출가능하게끔 제어가 가능 

- 호출시에만 실행되는 서버리스 형태

- 호출 비용은 월 200만회까지는 무료
    - 컴퓨팅 비용은 따로 부과됨
    - 참고 :  https://cloud.google.com/functions/pricing?hl=ko


## Slack API Cloud Function 배포 

- 런타임 : Python 3.11
- 진입점 : send_message

- 기존 Slack API 코드를 수정하여 사용
> main.py
```py
import os
import requests
from flask import jsonify

# 환경변수에서 Slack Token과 Channel ID 불러오기
SLACK_TOKEN = os.getenv('SLACK_TOKEN')
SLACK_CHANNEL = os.getenv('SLACK_CHANNEL')

# Cloud Function 핸들러
def send_message(request):
    data = request.get_json()
    text = data.get('text', 'Hello from Cloud Function!')

    # Slack API를 호출하여 메시지 전송
    response = requests.post('https://slack.com/api/chat.postMessage', json={
        'channel': SLACK_CHANNEL,
        'text': text
    }, headers={
        'Authorization': f'Bearer {SLACK_TOKEN}',
        'Content-Type': 'application/json'
    })

    return jsonify(response.json()), response.status_code

```
> requirements.txt
```
Flask==2.3.2
requests==2.31.0
gunicorn>=22.0.0
```

### 배포 후 정상 작동 테스트 
- 트리거 (호출 URL 확인)하여 해당 URL로 호출  테스트 

```sh
$ curl -X POST https://asia-northeast3-gcp-in-ca.cloudfunctions.net/slack-api -H "Content-Type: application/json" -d '{"text": "Hello from Cloud Function!"}'

{"channel":"C075QKNQZJN","message":{"app_id":"A075QGZPSUB","blocks":[{"block_id":"DA0","elements":[{"elements":[{"text":"Hello from Cloud Function!","type":"text"}],"type":"rich_text_section"}],"type":"rich_text"}],"bot_id":"B07Q9PEJZB2","bot_profile":{"app_id":"A075QGZPSUB","deleted":false,"icons":{"image_36":"https://a.slack-edge.com/80588/img/plugins/app/bot_36.png","image_48":"https://a.slack-edge.com/80588/img/plugins/app/bot_48.png","image_72":"https://a.slack-edge.com/80588/img/plugins/app/service_72.png"},"id":"B07Q9PEJZB2","name":"test-app","team_id":"T07639T5HFB","updated":1727680976},"team":"T07639T5HFB","text":"Hello from Cloud Function!","ts":"1727855635.534319","type":"message","user":"U076DDF2PHN"},"ok":true,"response_metadata":{"warnings":["missing_charset"]},"ts":"1727855635.534319","warning":"missing_charset"}
```