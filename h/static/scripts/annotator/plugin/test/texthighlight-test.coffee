Annotator = require('annotator')
$ = Annotator.$

th = require('../texthighlights')

assert = chai.assert
sinon.assert.expose(assert, prefix: '')


describe 'Annotator.Plugin.TextHighlight', ->
  sandbox = null
  scrollTarget = null

  createTestHighlight = ->
    anchor =
      id: "test anchor"
      annotation: "test annotation"
      anchoring:
        id: "test anchoring manager"
        annotator:
          id: "test annotator"
          element:
            delegate: sinon.spy()

    new th.TextHighlight anchor, "test page", "test range"

  beforeEach ->
    sandbox = sinon.sandbox.create()
    sandbox.stub th.TextHighlight, 'highlightRange',
      (normedRange, cssClass) ->
        hl = document.createElement "hl"
        hl.appendChild document.createTextNode "test highlight span"
        hl

    Annotator.$.fn.scrollintoview = sinon.spy (options) ->
      scrollTarget = this[0]
      options?.complete?()

  afterEach ->
    sandbox.restore()
    scrollTarget = null

  describe "constructor", ->
    it 'wraps a highlight span around the given range', ->
      hl = createTestHighlight()
      assert.calledWith th.TextHighlight.highlightRange, "test range"

    it 'stores the created highlight spans in _highlights', ->
      hl = createTestHighlight()
      assert.equal hl._highlights.textContent, "test highlight span"

    it "assigns the annotation as data to the highlight span", ->
      hl = createTestHighlight()
      annotation = Annotator.$(hl._highlights).data "annotation"
      assert.equal annotation, "test annotation"

  describe "getBoundingClientRect", ->

    it 'returns the bounding box of all the highlight client rectangles', ->
      rects = [
        {
          top: 20
          left: 15
          bottom: 30
          right: 25
        }
        {
          top: 10
          left: 15
          bottom: 20
          right: 25
        }
        {
          top: 15
          left: 20
          bottom: 25
          right: 30
        }
        {
          top: 15
          left: 10
          bottom: 25
          right: 20
        }
      ]
      fakeHighlights = rects.map (r) ->
        return getBoundingClientRect: -> r
      hl = _highlights: fakeHighlights
      result = th.TextHighlight.prototype.getBoundingClientRect.call(hl)
      assert.equal(result.left, 10)
      assert.equal(result.top, 10)
      assert.equal(result.right, 30)
      assert.equal(result.bottom, 30)

  describe "scrollToView", ->

    it 'calls jQuery scrollintoview', ->
      hl = createTestHighlight()
      hl.scrollToView()
      assert.called Annotator.$.fn.scrollintoview

    it 'scrolls to the created highlight span', ->
      hl = createTestHighlight()
      hl.scrollToView()
      assert.equal scrollTarget, hl._highlights
