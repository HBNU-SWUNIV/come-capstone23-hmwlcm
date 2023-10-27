# 한밭대학교 트래블링 컴패니언팀

**팀구성**
+ 20191793 한민우
+ 20182658 이창민
# Project Background
+ **배경 분석**
  + 컨슈머인사이트에서 조사한 2021년, 2022년 국내여행 여부를 살펴보면 2021년 1분기에 51.4%, 2분기에 57.8%, 3분기에 63.5%, 4분기에 67.7%이고, 2022년 1분기에 64.3%, 2분기에 64.9%, 3분기에 74.1%, 4분기에 73.5%로 코로나 펜데믹이 끝난 이후로 국내여행을 하는 사람들이 늘어나고 있음을 알 수 있다. 이러한 전망에 따라, 앞으로도 많은 사람들이 여행을 다닐 것으로 예측되고, 여행 어플에 대한 수요도 증가할 것으로 예상된다.

+ **기존 문제점**
  + 일반적인 여행 어플들은 추천 여행지를 글과 사진만으로 표현하거나, 지도에 위치만 보여주거나 하는 식으로 간단한 구성을 하고 있다. 그렇기에 소개글이 잘못 써져있거나 설명이 부족하다면 해당 여행지에 대해 판단할 정보가 없다.
  + 소개글이나 리뷰를 직접 1개씩 읽어보지 않는 이상 여행지가 어떤 느낌이고 어떤 환경인지를 알 수 없다.
  + 가고자 하는 여행지가 많아지면 많아질수록 여행 계획 시의 이동 계획 설계에 많은 시간이 소요된다.
 
+ **필요성**
  + 여행지의 위치 표시와 자동차 이동 경로 표시, 이동 시간 표시, 자동 일정 추천 등의 기능들을 통해 여행 계획을 세우는데 시간을 효율적으로 사용할 수 있게 될 것이다.
  + 글을 일일이 읽어야만 하는 점에 대해서 여행지 정보를 점수로 매겨 지표화를 통해 그래픽적인 평가를 한 눈에 보게 한다. 이를 통해 사람들이 여행지에 대해 조사할 때 정보를 빠르게 파악할 수 있게 될 것이다.
  + 여행지에 대해 모르는 채로 검색하게될 상황에 대해 개발 어플리케이션에서 ChatGPT를 활용한 챗봇AI 기능을 제공한다. 이를 통해 AI에게 간단히 질문한 후 해당 답변을 키워드로 추가적인 정보를 조사할 수 있게되어 조사 시간을 절약할 수 있게 될 것이다.

+ **프로젝트 목표**
  + 여행지 일정 관리를 도와주며, 각 여행지 간의 이동 경로를 보여주어 이동 계획에도 도움을 줄 수 있다. 무료 입장 여행지를 추천해주며 해당 여행지들 리뷰의 지표화를 통한 효과적인 정보 전달로, 여행 계획을 세우는 것에 도움을 주는 어플을 개발하는 것이다.
# System Design
+ **시스템 구성도**
  
<img src = "https://user-images.githubusercontent.com/128362238/270866514-e595d0ce-909b-492d-b2df-1c6071c57d30.PNG" width="90%"></img>

+ **개발 기능**
  + 개발 어플리케이션의 핵심 기능 중 하나인 여행지 특성 지표는 ChatGPT를 이용하고 있다. 웹크롤링으로 얻은 정보를 ChatGPT에게 질문하고, 이를 받아 특성 지표 그림으로 표현한다.
    
<img src = "https://user-images.githubusercontent.com/128362238/270867098-e5fd5152-973f-458a-8ee7-1cb4d7c9937b.png" width="90%"></img>

  + 해당 사진은 개발 과정 중 ChatGPT가 어떤 평가를 하고, 어떻게 점수를 매기는 가를 테스트한 사진이다. 어플리케이션에는 아래의 사진과 같은 형식으로 적용된다. ChatGPT 페이지와 점수 요청 기준이 다른 이유는 테스트하기 위해 적용했던 사진이기 때문이다.
    
<img src = "https://user-images.githubusercontent.com/128362238/270867489-0fe74c74-04fa-4c72-bcec-745201684c76.png" width="90%"></img>

  + AI 챗봇 시스템도 ChatGPT를 이용한다. ChatGPT에게 기본 역할을 알려준 후, 사용자와 대화를 시킨다.
    
<img src = "https://user-images.githubusercontent.com/128362238/270867548-44c2add8-8608-49a3-a542-76e3f36aaab6.png" width="90%"></img>

# Case Study
+ **웹크롤링**
  + www.tripadvisor.co.kr 를 웹크롤링하여 이를 엑셀로 저장했다. 이때, 무료 입장 여행지들의 정보와 리뷰를 웹크롤링하였다.
    
<img src = "https://user-images.githubusercontent.com/128362238/270866719-2ea9eadb-16ac-4aee-9364-2c70b96cd37a.png" width="90%"></img>

  + 이후 이를 MySQL에 저장하여 개발 어플리케이션에 활용하고 있다.
    
<img src = "https://user-images.githubusercontent.com/128362238/270866838-2e152345-7db5-4b2b-85aa-2eff6d9c73dd.png" width="90%"></img>

+ **Tmap API 적용 경도 위도 변환**
  + 여행지의 내비게이션 지도는 Google을, 이동 경로 표시에 대한 정보 획득에는 Tmap API 사용한다. 이때 Google 지도와 Tmap API에 여행지를 적용시키기 위해서는 경도와 위도가 필요하다. 웹크롤링을 통해 얻은 여행지 정보에는 경도와 위도가 없어서 해당 주소를 직접 변환 시켜야 했다.
    
<img src = "https://user-images.githubusercontent.com/128362238/270867623-8808d275-0d1e-4295-8dcc-b0034d8a4d47.png" width="90%"></img>

  + 경도 위도 변환 프로그램을 이용하여 우리가 사용하는 모든 여행지에 대해 주소를 변환시켰으며, 이를 엑셀에 저장하였다. 해당 엑셀 정보를 다시 MySQL에 저장하여 이를 어플리케이션에서 활용하고 있다.

<img src = "https://user-images.githubusercontent.com/128362238/270867707-b7fbf85e-e1de-4184-a631-96dbbee422a0.png" width="90%"></img>

+ **Tmap API 사용**
  + Tmap API를 통해 각 여행지별 이동거리, 이동시간을 알 수 있다. Tmap API에서도 여러 종류의 요청 url이 존재하는데, 해당 개발 어플리케이션에서는 Tmap API의 다중 경유지 요청 url을 사용한다. 이를 사용하기위해 Tmap API 요청 json 형식을 따라야 하는데, 이때 json 형식은 Tmap API 공식 사이트에서 확인할 수 있다.

<img src = "https://user-images.githubusercontent.com/128362238/272831534-7479d903-12da-4bb9-a0e4-920c0ace8461.PNG" width="90%"></img>

  + Tmap API에 필요한 json 형식은 아래의 함수 코드를 통해 여행지 순서에 맞추어 [ 여행지, 경도, 위도 ] 배열을 인자로 받는다. 여행지 순서에 따라 Tmap API 문서에서 지정한 json 형식으로 바꿔준다.

<img src = "https://user-images.githubusercontent.com/128362238/272831798-21b2605c-de7a-4407-8c95-8ae991812d9e.PNG" width="90%"></img>

  + Tmap API를 구현한 Web Server로 해당 json을 보내면, 그에 따른 Tmap API 결과 json을 받을 수 있다. 아래의 사진은 Web Server로 Tmap API에 대한 post요청을 보내는 부분의 코드이다.

<img src = "https://user-images.githubusercontent.com/128362238/272831670-822316b8-1f9f-445b-afed-aee47c9182f2.PNG" width="90%"></img>

  + Tmap API에서 반환해주는 json에 대한 샘플은 아래의 사진과 같다.

<img src = "https://user-images.githubusercontent.com/128362238/272831896-095e988c-e095-4938-a3e0-1c0d1c6eb490.PNG" width="90%"><img>

  + 반환받은 Tmap API json값을 그대로 이용할 수는 있지만, 복잡한 구조로 짜여진 json을 그대로 사용하기에는 쉽지 않다. 그래서, flutter에서 사용하기 쉽게 flutter 배열로 바꾸는 코드를 작성하였고, 이는 아래 사진과 같다. 주로 사용할 정보는 [ 여행지 이름, 이동시간, 이동거리 ] 이기때문에 해당 값만을 배열로 바꾸었다.

<img src ="https://user-images.githubusercontent.com/128362238/272832025-825fe6fb-3704-49d9-98db-214cdf0ca622.PNG" width="90%"><img>

  + 바꾼 배열의 값이 제대로 작동하는 지 테스트하기 위해 작성한 출력 코드 일부는 아래와 같다. 

<img src ="https://user-images.githubusercontent.com/128362238/272832102-e1f9fbb1-2247-4adf-8de4-3f56d32580c9.PNG" width="90%"></img>

  + Web Server에서 post 요청을 받아 Tmap API 결과 json을 반환하는 부분에 대한 일부 코드는 아래와 같다. Web Server는 Apache의 html에 php언어를 적용하여 작성하였다.

<img src ="https://user-images.githubusercontent.com/128362238/272840284-bba69bed-d185-4b4f-add1-7019773eb836.PNG" width="90%"></img>

  + Apache에 적용한 PHP 언어의 기본 info는 아래의 사진과 같다.

<img src ="https://user-images.githubusercontent.com/128362238/274367406-0c70059f-81c5-454c-aa65-733e38c0d720.PNG" width="90%"></img>
 
# Conclusion
+ **개발 어플리케이션 문제점**
  + 높은 AI 의존도
     + 개발 어플리케이션의 주요 부분 중 여행지 특성 지표화와 AI 챗봇 시스템은 해당 AI 기업의 데이터 저쟝율에 따라 정확도가 달라진다.
       웹크롤링을 통해 얻은 여행지에 대한 정보가 AI 회사에 저장되어 있지 않다면, 사용하는 AI의 특징에 따라 사용자의 여행지 관련 질문에 답변을 하지 않거나 AI 기준에서 모르는 여행지에 대해 답변이 창조될 수도 있다.

       이를 해결하기 위해서는 저장되어 있는 모든 여행지에 대한 정보를 AI에게 질문해보고, AI의 답변을 사람이 일일이 웹크롤링으로 얻은 정보와 비교를 하며 사용할 수 있는 여행지와 없는 여행지를 검증해야한다.
       또 다른 방법으로는 AI회사에서 해당 AI에 대한 성능을 업그레이드할 때 우리나라의 모든 여행지에 대해서도 정보가 저장되기를 기다리는 것이다.

       이 두가지 모두 현재 상황으로는 해결하기에 적합한 방법이 아니므로 그 외의 적절한 해결 방법을 발견하기 전 까지 현 상황이 유지될 것이다.

# Project Outcome(대회 참가 시)
