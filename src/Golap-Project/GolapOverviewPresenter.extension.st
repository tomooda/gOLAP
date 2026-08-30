Extension { #name : 'GolapOverviewPresenter' }

{ #category : '*Golap-Project' }
GolapOverviewPresenter >> asJSON [

	^ super asJSON
		  at: 'scale' put: scale;
		  at: 'offset' put: {
				  offset x.
				  offset y };
		  at: 'nodePositions' put: (nodePositions associations collect: [ :assoc |
						   assoc key -> {
								   assoc value x.
								   assoc value y } ]) asDictionary;
		  yourself
]

{ #category : '*Golap-Project' }
GolapOverviewPresenter >> fromJSON: aDictionary [

	super fromJSON: aDictionary.
	aDictionary
		at: 'scale' ifPresent: [ :num | scale := num ];
		at: 'offset' ifPresent: [ :array | offset := array first @ array second ];
		at: 'nodePositions' ifPresent: [ :dict |
			nodePositions := (dict associations collect: [ :assoc | assoc key -> (assoc value first @ assoc value second) ]) asDictionary ]
]
