Extension { #name : 'GolapCSVEdgeImporterPresenter' }

{ #category : '*Golap-Project' }
GolapCSVEdgeImporterPresenter >> asJSON [

	^ super asJSON
		  at: 'idDropList1' put: idDropList1 selectedIndex;
		  at: 'idDropList2' put: idDropList2 selectedIndex;
		  yourself
]

{ #category : '*Golap-Project' }
GolapCSVEdgeImporterPresenter >> fromJSON: aDictionary [

	super fromJSON: aDictionary.
	aDictionary
		at: 'idDropList1'
		ifPresent: [ :integer | idDropList1 selectIndex: integer ];
		at: 'idDropList2'
		ifPresent: [ :integer | idDropList2 selectIndex: integer ]
]
