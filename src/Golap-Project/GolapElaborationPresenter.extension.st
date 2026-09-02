Extension { #name : 'GolapElaborationPresenter' }

{ #category : '*Golap-Project' }
GolapElaborationPresenter >> asJSON [

	^ super asJSON
		  at: 'gap' put: gapSlider value;
		  at: 'scale' put: {
				  scale x.
				  scale y };
		  at: 'offset' put: {
				  offset x.
				  offset y } ;
		  yourself
]

{ #category : '*Golap-Project' }
GolapElaborationPresenter >> fromJSON: aDictionary [

	super fromJSON: aDictionary.
	aDictionary
		at: 'gap' ifPresent: [ :num | gapSlider value: num ];
		at: 'scale' ifPresent: [ :array | scale := array first @ array second ];
		at: 'offset' ifPresent: [ :array | offset := array first @ array second ].
	self updateTree
]
