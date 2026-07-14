Extension { #name : 'GolapPolishOverviewPresenter' }

{ #category : '*Golap-Project' }
GolapPolishOverviewPresenter >> asJSON [

	^ super asJSON
		  at: 'polishIteration' put: polishRepeatsCheckbox state;
		  at: 'positivePolish' put: polishAdditionThresholdField number;
		  at: 'negativePolish' put: polishRemovalThresholdField number;
		  at: 'polishMinDenominator' put: polishMinClusterSize number;
		  at: 'showsPolishEdges' put: showsPolishEdgesCheckbox state;
		  yourself
]

{ #category : '*Golap-Project' }
GolapPolishOverviewPresenter >> fromJSON: aDictionary [

	super fromJSON: aDictionary.
	aDictionary
		at: 'polishIteration'
		ifPresent: [ :bool | polishRepeatsCheckbox state: bool ];
		at: 'positivePolish'
		ifPresent: [ :number | polishAdditionThresholdField number: number ];
		at: 'negativePolish'
		ifPresent: [ :number | polishRemovalThresholdField number: number ];
		at: 'polishMinDenominator'
		ifPresent: [ :integer | polishMinClusterSize number: integer ];
		at: 'showsPolishEdges'
		ifPresent: [ :bool | showsPolishEdgesCheckbox state: bool ].
	self updateGraph
]
