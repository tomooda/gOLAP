Extension { #name : 'GolapPolishOverviewPresenter' }

{ #category : '*Golap-Project' }
GolapPolishOverviewPresenter >> asJSON [

	^ super asJSON
		  at: 'visibleEdgeMinPercentile'
		  put: visibleEdgeMinPercentileSlider value;
		  at: 'visibleEdgeMaxPercentile'
		  put: visibleEdgeMaxPercentileSlider value;
		  at: 'polishIteration' put: polishIterationCheckbox state;
		  at: 'positivePolish' put: positivePolishField number;
		  at: 'negativePolish' put: negativePolishField number;
		  at: 'polishMinDenominator' put: polishMinDenominatorField number;
		  at: 'showsPolishEdges' put: showsPolishEdgesCheckbox state;
		  yourself
]

{ #category : '*Golap-Project' }
GolapPolishOverviewPresenter >> fromJSON: aDictionary [

	super fromJSON: aDictionary.
	aDictionary
		at: 'visibleEdgeMinPercentile'
		ifPresent: [ :number | visibleEdgeMinPercentileSlider value: number ];
		at: 'visibleEdgeMaxPercentile'
		ifPresent: [ :number | visibleEdgeMaxPercentileSlider value: number ];
		at: 'polishIteration'
		ifPresent: [ :bool | polishIterationCheckbox state: bool ];
		at: 'positivePolish'
		ifPresent: [ :number | positivePolishField number: number ];
		at: 'negativePolish'
		ifPresent: [ :number | negativePolishField number: number ];
		at: 'polishMinDenominator'
		ifPresent: [ :integer | polishMinDenominatorField number: integer ];
		at: 'showsPolishEdges'
		ifPresent: [ :bool | showsPolishEdgesCheckbox state: bool ].
	self updateGraph
]
