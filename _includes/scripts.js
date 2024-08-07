document.addEventListener("DOMContentLoaded", function () {
  const codeBlocks = document.querySelectorAll("pre");

  codeBlocks.forEach((block) => {
    const button = document.createElement("button");
    button.innerText = "코드 복사";
    button.classList.add("copy-button");

    // 버튼 클릭 시 코드 복사
    button.addEventListener("click", () => {
      const code = block.querySelector("code").innerText;
      navigator.clipboard.writeText(code).then(() => {
        button.innerText = "복사 완료!";
        setTimeout(() => {
          button.innerText = "코드 복사";
        }, 2000);
      });
    });

    block.appendChild(button); // 버튼을 코드 블록에 추가
  });
});
