Extension { #name : 'GolapHEBChartPresenter' }

{ #category : '*Golap-Project' }
GolapHEBChartPresenter >> fromJSON: aDictionary [

	super fromJSON: aDictionary.
	self updateAngles
]
