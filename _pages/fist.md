---
layout: default
title: 유튜브 구독
permalink: /subscribe/
---

<style>
  body {
    font-family: 'Segoe UI', sans-serif;
    text-align: center;
    background: linear-gradient(135deg, #1a1a1a 0%, #333 100%);
    color: #f5f5f5;
    padding: 60px 20px;
    animation: fadeIn 2s ease;
  }

  h1 {
    font-size: 2.8em;
    margin-bottom: 10px;
    animation: bounce 1.5s infinite;
    color: #ff5e5e;
  }

  p {
    font-size: 1.3em;
    margin-bottom: 40px;
    opacity: 0.85;
  }

  .subscribe-btn {
    background-color: #e50914;
    color: white;
    padding: 15px 30px;
    font-size: 1.2em;
    border: none;
    border-radius: 30px;
    cursor: pointer;
    transition: all 0.3s ease;
    box-shadow: 0 4px 15px rgba(255, 0, 0, 0.3);
  }

  .subscribe-btn:hover {
    background-color: #b20710;
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

<h1> 허배달 유튜브 구독하러 GO GO !</h1>
<p>구독은 나의힘 구독해주시고 더 많은 정보를 알아보세요!</p>
<button class="subscribe-btn" onclick="openSubscribe()">구독하고 계속하기</button>

<script>
  function openSubscribe() {
    window.open("https://www.youtube.com/@herdeli?sub_confirmation=1", "_blank");
    window.location.href = "https://herkss.github.io/fist.md";
  }
</script>
