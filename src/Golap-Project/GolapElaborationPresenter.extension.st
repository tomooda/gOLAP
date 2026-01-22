Extension { #name : 'GolapElaborationPresenter' }

{ #category : '*Golap-Project' }
GolapElaborationPresenter >> asJSON [

	^ {
		  ('gap' -> gapSlider value).
		  ('scale' -> {
			   scale x.
			   scale y }).
		  ('offset' -> {
			   offset x.
			   offset y }) } asDictionary
]

{ #category : '*Golap-Project' }
GolapElaborationPresenter >> fromJSON: aDictionary [

	aDictionary
		at: 'gap' ifPresent: [ :num | gapSlider value: num ];
		at: 'scale'
		ifPresent: [ :array | scale := array first @ array second ];
		at: 'offset'
		ifPresent: [ :array | offset := array first @ array second ].
	self updateTree
]
