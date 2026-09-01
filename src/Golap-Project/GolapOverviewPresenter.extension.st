Extension { #name : 'GolapOverviewPresenter' }

{ #category : '*Golap-Project' }
GolapOverviewPresenter >> asJSON [

	^ super asJSON
		  at: 'scale' put: scale;
		  at: 'offset' put: {
				  offset x.
				  offset y };
		  yourself
]

{ #category : '*Golap-Project' }
GolapOverviewPresenter >> fromJSON: aDictionary [

	super fromJSON: aDictionary.
	aDictionary
		at: 'scale' ifPresent: [ :num | scale := num ];
		at: 'offset' ifPresent: [ :array | offset := array first @ array second ]
]
