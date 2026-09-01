Extension { #name : 'GolapGraphOverviewPresenter' }

{ #category : '*Golap-Project' }
GolapGraphOverviewPresenter >> asJSON [

	^ super asJSON
		  at: 'nodePositions' put: (nodePositions associations collect: [ :assoc |
						   assoc key -> {
								   assoc value x.
								   assoc value y } ]) asDictionary;
		  yourself
]

{ #category : '*Golap-Project' }
GolapGraphOverviewPresenter >> fromJSON: aDictionary [

	super fromJSON: aDictionary.
	aDictionary
		at: 'nodePositions' ifPresent: [ :dict |
			nodePositions := (dict associations collect: [ :assoc | assoc key -> (assoc value first @ assoc value second) ]) asDictionary ]
]
