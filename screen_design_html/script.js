(function () {
  var timerEl = document.getElementById("timer");
  var barEl = document.getElementById("bar");
  var startBtn = document.getElementById("start-demo");
  var answerDisplayEl = document.getElementById("answer-display");
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
    startBtn.classList.add("is-hidden");
    problemEl.classList.remove("is-hidden-problem");
  });

  if (!answerDisplayEl || !problemEl || !judgeEl) return;
  var answer = (problemEl.getAttribute("data-romaji") || "").toLowerCase();
  var typed = "";

  function renderJudge() {
    answerDisplayEl.textContent = typed;

    if (!typed) {
      judgeEl.textContent = "";
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
  }

  window.addEventListener("keydown", function (e) {
    if (e.metaKey || e.ctrlKey || e.altKey) return;
    if (e.key === "Backspace") {
      typed = typed.slice(0, -1);
      renderJudge();
      e.preventDefault();
      return;
    }
    if (e.key === "Escape") {
      typed = "";
      renderJudge();
      return;
    }
    if (/^[a-zA-Z]$/.test(e.key)) {
      typed += e.key.toLowerCase();
      renderJudge();
      e.preventDefault();
    }
  });
})();
