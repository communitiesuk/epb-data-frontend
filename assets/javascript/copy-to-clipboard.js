class CopyToClipboardElement extends HTMLElement {
  #timeout

  connectedCallback () {
    if (!navigator.clipboard) {
      this.hidden = true
      return
    }
    this.#button?.addEventListener('click', this.#onClick)
  }

  disconnectedCallback () {
    clearTimeout(this.#timeout)
    this.#button?.removeEventListener('click', this.#onClick)
  }

  get target () {
    const element = this.ownerDocument.getElementById(
      this.getAttribute('target')
    )
    if (!element) {
      console.warn('missing target element for', this)
    }
    return element
  }

  get #button () {
    return this.querySelector('button')
  }

  #onClick = async (e) => {
    if (e.defaultPrevented) {
      return
    }
    clearTimeout(this.#timeout)
    try {
      await navigator.clipboard.writeText(this.target?.textContent?.trim())
    } catch (e) {
      console.error(e)
      return
    }
    this.#setSlotHidden('action-message', true)
    this.#setSlotHidden('success-message', false)
    this.#timeout = setTimeout(() => this.#reset(), 5000)
  }

  #reset () {
    this.#setSlotHidden('action-message', false)
    this.#setSlotHidden('success-message', true)
  }

  #setSlotHidden (name, state) {
    const element = this.querySelector(`slot[name="${name}"]`)
    if (!element) {
      console.warn(`missing slot ${name}`, this)
      return
    }
    element.hidden = state
  }
}

customElements.define('epb-copy-to-clipboard', CopyToClipboardElement)
