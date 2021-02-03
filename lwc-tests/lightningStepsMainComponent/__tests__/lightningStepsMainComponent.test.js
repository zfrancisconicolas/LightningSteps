import { createElement } from 'lwc';
import LightningStepsMainComponent from 'c/lightningStepsMainComponent';


describe('c-lightning-steps-main-component', () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it('tests child components creation', () => {
    const element = createElement('c-lightning-steps-main-component', {
      is: LightningStepsMainComponent
    });
    document.body.appendChild(element);

    return Promise.resolve().then(() => {
      let detailEls = element.shadowRoot.querySelectorAll('c-lightning-steps-product-list');
      expect(detailEls.length).toBe(1);
      detailEls = element.shadowRoot.querySelectorAll('c-lightning-steps-shopping-cart');
      expect(detailEls.length).toBe(1);
      detailEls = element.shadowRoot.querySelectorAll('c-lightning-steps-product-preview');
      expect(detailEls.length).toBe(1);
    });
  });
});