(function () {
  var timerEl = document.getElementById("timer");
  var barEl = document.getElementById("bar");
  var startBtn = document.getElementById("start-demo");
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
})();
