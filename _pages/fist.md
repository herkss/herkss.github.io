---
layout: default
title: 유튜브 구독
permalink: /subscribe/
---


<style>
  body {
    font-family: -apple-system, BlinkMacSystemFont, 'Helvetica Neue', sans-serif;
    background-color: #1c1c1e;
    color: #f2f2f7;
    text-align: center;
    padding: 80px 20px;
    animation: fadeIn 1.2s ease;
  }

  h1 {
    font-size: 2.5rem;
    margin-bottom: 16px;
    font-weight: 600;
    color: #ff453a;
  }

  p {
    font-size: 1.15rem;
    opacity: 0.85;
    margin-bottom: 40px;
    line-height: 1.6;
  }

  .subscribe-btn {
    display: inline-block;
    background-color: #0a84ff;
    color: #ffffff;
    padding: 14px 28px;
    font-size: 17px;
    font-weight: 500;
    border-radius: 12px;
    border: 0;
    transition: all 0.3s ease;
    box-shadow: 0 4px 14px rgba(10, 132, 255, 0.25);
    -webkit-tap-highlight-color: transparent;
  }

  .subscribe-btn:hover {
    background-color: #0077ed;
    box-shadow: 0 6px 18px rgba(10, 132, 255, 0.35);
  }

  .subscribe-btn:active {
    background-color: #005bb5;
    box-shadow: 0 2px 6px rgba(0, 0, 0, 0.4) inset;
    transform: scale(0.98);
  }

  @keyframes fadeIn {
    from { opacity: 0; transform: translateY(20px); }
    to { opacity: 1; transform: translateY(0); }
  }
</style>

<h1>유튜브 구독과 몽키피스트 사용법</h1>
<p>허배달구독하고.<br>몽키피스트 사용법 알아보자!</p>
<button class="subscribe-btn" onclick="openSubscribe()">구독하고 계속</button>
<h1>여성들의 든든한 호신용 악세서리</h1>
<h1>몽키피스트 구입문의 </h1>
<h1>010-9642-4467 </h1>
<h1>문자로 문의해주세요!! </h1>

<script>
  function openSubscribe() {
    window.open("https://www.youtube.com/@herdeli?sub_confirmation=1", "_blank");
    window.location.href = "https://herkss.github.io/dart/monkeyfist/";
  }
</script>
