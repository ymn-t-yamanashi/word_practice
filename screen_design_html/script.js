(function () {
  var timerEl = document.getElementById("timer");
  var barEl = document.getElementById("bar");
  var startBtn = document.getElementById("start-demo");
  var inputEl = document.getElementById("answer-input");
  var problemEl = document.getElementById("problem");
  var judgeEl = document.getElementById("judge-status");
  if (!timerEl || !barEl || !startBtn) return;

  var total = 30;
  var left = total;
  var t = null;

  function render() {
    timerEl.textContent = left + "s";
    barEl.style.width = (left / total) * 100 + "%";
  }

  function tick() {
    left -= 1;
    if (left < 0) {
      clearInterval(t);
      t = null;
      return;
    }
    render();
  }

  startBtn.addEventListener("click", function () {
    if (t) clearInterval(t);
    left = total;
    render();
    t = setInterval(tick, 1000);
  });

  if (!inputEl || !problemEl || !judgeEl) return;
  var answer = (problemEl.getAttribute("data-romaji") || "").toLowerCase();

  inputEl.addEventListener("input", function () {
    var typed = inputEl.value.trim().toLowerCase();

    if (!typed) {
      judgeEl.textContent = "入力中にリアルタイム判定します";
      judgeEl.style.color = "";
      return;
    }

    if (typed === answer) {
      judgeEl.textContent = "正解";
      judgeEl.style.color = "#2f8f62";
      return;
    }

    if (answer.indexOf(typed) === 0) {
      judgeEl.textContent = "入力中（ここまで正しい）";
      judgeEl.style.color = "";
      return;
    }

    judgeEl.textContent = "不一致（ローマ字を確認）";
    judgeEl.style.color = "#b34d2e";
  });
})();
