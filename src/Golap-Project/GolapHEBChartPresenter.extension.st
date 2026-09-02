Extension { #name : 'GolapHEBChartPresenter' }

{ #category : '*Golap-Project' }
GolapHEBChartPresenter >> asJSON [

	^ super asJSON
		  at: 'attribute' put: attributeDropList selectedItem;
		  yourself
]

{ #category : '*Golap-Project' }
GolapHEBChartPresenter >> fromJSON: aDictionary [

	super fromJSON: aDictionary.
	aDictionary at: 'attribute' ifPresent: [ :string |
			self updateAttributeDropList.
			(attributeDropList items includes: string) ifTrue: [ attributeDropList selectItem: string ] ].
	self updateAngles
]
