---
layout: default
title: 유튜브 구독
permalink: /subscribe/
---

<h2>아래 버튼을 눌러 유튜브 구독을 해주세요!</h2>
<button onclick="openSubscribe()">구독하고 계속하기</button>

<script>
  function openSubscribe() {
    window.open("https://www.youtube.com/channel/채널ID?sub_confirmation=1", "_blank");
    window.location.href = "https://your-homepage.com";
  }
</script>
