---
layout: default
title: 유튜브 구독
permalink: /subscribe/
---

<style>
  body {
    font-family: 'Segoe UI', sans-serif;
    text-align: center;
    background: linear-gradient(135deg, #ffecd2 0%, #fcb69f 100%);
    color: #333;
    padding: 60px 20px;
    animation: fadeIn 2s ease;
  }

  h1 {
    font-size: 2.8em;
    margin-bottom: 10px;
    animation: bounce 1.5s infinite;
  }

  p {
    font-size: 1.3em;
    margin-bottom: 40px;
    opacity: 0.9;
  }

  .subscribe-btn {
    background-color: #ff4444;
    color: white;
    padding: 15px 30px;
    font-size: 1.2em;
    border: none;
    border-radius: 30px;
    cursor: pointer;
    transition: all 0.3s ease;
    box-shadow: 0 4px 15px rgba(0,0,0,0.2);
  }

  .subscribe-btn:hover {
    background-color: #cc0000;
    transform: scale(1.05);
  }

  @keyframes fadeIn {
    from { opacity: 0; transform: translateY(30px); }
    to { opacity: 1; transform: translateY(0); }
  }

  @keyframes bounce {
    0%, 100% { transform: translateY(0); }
    50% { transform: translateY(-10px); }
  }
</style>

<h1>유튜브 구독하고 혜택 받기!</h1>
<p>구독하시면 더 많은 꿀정보와 콘텐츠가 기다리고 있어요!</p>
<button class="subscribe-btn" onclick="openSubscribe()">구독하고 계속하기</button>

<script>
  function openSubscribe() {
    window.open("https://www.youtube.com/herdeli?sub_confirmation=1", "_blank");
    window.location.href = "https://your-homepage.com";
  }
</script>
