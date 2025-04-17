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

<h1> 허배달 유튜브 구독하러 GO GO !</h1>
<h1> 몽키피스트 사용방법을 알아봅시다~</h1>
<p>구독은 나의힘 구독해주시고 더 많은 정보를 알아보세요!</p>
<button class="subscribe-btn" onclick="openSubscribe()">구독하고 계속하기</button>

<script>
  function openSubscribe() {
    window.open("https://www.youtube.com/@herdeli?sub_confirmation=1", "_blank");
    window.location.href = "https://herkss.github.io/dart/monkeyfist/";
  }
</script>
