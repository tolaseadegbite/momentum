import { Controller } from "@hotwired/stimulus"
import { Chart, registerables } from "chart.js"
Chart.register(...registerables)

export default class extends Controller {
  static values = { type: String, labels: Array, data: Array, label: String }

  connect() {
    const ctx = this.element.getContext("2d")
    const gradient = ctx.createLinearGradient(0, 0, 0, 220)
    gradient.addColorStop(0, "rgba(196,113,42,.35)")
    gradient.addColorStop(1, "rgba(196,113,42,0)")

    new Chart(ctx, {
      type: this.typeValue || "line",
      data: {
        labels: this.labelsValue,
        datasets: [{
          label: this.labelValue || "Check-ins",
          data: this.dataValue,
          borderColor: "#1B1031",
          backgroundColor: this.typeValue === "bar" ? "#C4712A" : gradient,
          fill: this.typeValue !== "bar",
          tension: 0.4,
          borderWidth: 2.5,
          pointRadius: 3,
          pointBackgroundColor: "#FAF7F2",
          pointBorderColor: "#C4712A",
          borderRadius: 8
        }]
      },
      options: {
        plugins: { legend: { display: false } },
        scales: {
          y: { beginAtZero: true, ticks: { stepSize: 1, color: "#A8A29E" }, grid: { color: "#EDE7DB" } },
          x: { ticks: { color: "#A8A29E" }, grid: { display: false } }
        }
      }
    })
  }
}
