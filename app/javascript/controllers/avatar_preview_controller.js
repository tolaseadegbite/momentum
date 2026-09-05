import { Controller } from "@hotwired/stimulus"

// Live avatar preview: when a file is picked in settings, show it instantly
// in the settings preview AND in the sidebar (same object URL works
// document-wide). The sidebar syncs again from the server after Save.
export default class extends Controller {
  static targets = ["input", "preview", "hint"]

  preview() {
    const file = this.inputTarget.files[0]
    if (!file) return

    if (!file.type.startsWith("image/")) {
      this.hintTarget.textContent = "Please choose an image file (PNG, JPG, GIF or WebP)."
      this.hintTarget.classList.remove("hidden")
      this.inputTarget.value = ""
      return
    }
    this.hintTarget.classList.add("hidden")

    if (this._objectUrl) URL.revokeObjectURL(this._objectUrl)
    this._objectUrl = URL.createObjectURL(file)

    this.showIn(this.previewTarget)
    const sidebar = document.getElementById("sidebar_avatar")
    if (sidebar) this.showIn(sidebar)
  }

  showIn(container) {
    container.querySelectorAll("img, span").forEach((el) => el.classList.add("hidden"))
    let img = container.querySelector('img[data-preview="true"]')
    if (!img) {
      img = document.createElement("img")
      img.dataset.preview = "true"
      img.alt = "Avatar preview"
      img.className = container.querySelector("span, img")?.className ?? "w-12 h-12 rounded-full object-cover ring-1 ring-stone-900/15"
      container.prepend(img)
    }
    img.src = this._objectUrl
    img.classList.remove("hidden")
  }

  disconnect() {
    if (this._objectUrl) URL.revokeObjectURL(this._objectUrl)
  }
}
