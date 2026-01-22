Extension { #name : 'GolapCSVNodeImporterPresenter' }

{ #category : '*Golap-Project' }
GolapCSVNodeImporterPresenter >> asJSON [

	^ super asJSON
		  at: 'idDropList' put: idDropList selectedIndex;
		  at: 'nameDropList' put: nameDropList selectedIndex;
		  at: 'photoUrlColumnDropList'
		  put: photoUrlColumnDropList selectedIndex;
		  yourself
]

{ #category : '*Golap-Project' }
GolapCSVNodeImporterPresenter >> fromJSON: aDictionary [

	super fromJSON: aDictionary.
	aDictionary
		at: 'idDropList'
		ifPresent: [ :integer | idDropList selectIndex: integer ];
		at: 'nameDropList'
		ifPresent: [ :integer | nameDropList selectIndex: integer ];
		at: 'photoUrlColumnDropList'
		ifPresent: [ :integer | photoUrlColumnDropList selectIndex: integer ]
]
