Extension { #name : 'GolapPolishOverviewPresenter' }

{ #category : '*Golap-Project' }
GolapPolishOverviewPresenter >> asJSON [

	^ super asJSON
		  at: 'polishToConverge' put: polishToConvergeCheckBox state;
		  at: 'fillerThreshold' put: fillerThresholdField number;
		  at: 'burrThreshold' put: burrThresholdField number;
		  at: 'minClusterSize' put: minClusterSizeField number;
		  yourself
]

{ #category : '*Golap-Project' }
GolapPolishOverviewPresenter >> fromJSON: aDictionary [

	super fromJSON: aDictionary.
	aDictionary
		at: 'polishToConverge'
		ifPresent: [ :bool | polishToConvergeCheckBox state: bool ];
		at: 'fillerThreshold'
		ifPresent: [ :number | fillerThresholdField number: number ];
		at: 'burrThreshold'
		ifPresent: [ :number | burrThresholdField number: number ];
		at: 'minClusterSize'
		ifPresent: [ :integer | minClusterSizeField number: integer ].
	self updateGraph
]
