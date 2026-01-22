Extension { #name : 'GolapCSVImportPresenter' }

{ #category : '*Golap-Project' }
GolapCSVImportPresenter >> asJSON [

	^ {
		  ('columnsTable-selectionIndex' -> columnsTable selectedIndex).
		  ('evaluatorDropList-selectionIndex'
		   -> evaluatorDropList selectedIndex) } asOrderedDictionary
]

{ #category : '*Golap-Project' }
GolapCSVImportPresenter >> fromJSON: aDictionary [

	aDictionary
		at: 'columnsTable-selectionIndex'
		ifPresent: [ :integer | columnsTable selectIndex: integer ];
		at: 'evaluatorDropList-selectionIndex'
		ifPresent: [ :integer | evaluatorDropList selectIndex: integer ]
]
