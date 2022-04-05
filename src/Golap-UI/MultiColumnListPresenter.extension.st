Extension { #name : #MultiColumnListPresenter }

{ #category : #'*Golap-UI' }
MultiColumnListPresenter >> selectedItems [
	"<api: #inspect>"

	"Return all the selected items in the case of a multiple selection list"

	^ multiSelectionHolder keys
		select: [ :index | multiSelectionHolder at: index ]
		thenCollect: [ :index | self listItems at: index ifAbsent: [ nil ] ]
]

{ #category : #'*Golap-UI' }
MultiColumnListPresenter >> selectedItems: aCollection [
	| newSelections |
	newSelections := aCollection asIdentitySet.
	1 to: self listItems size do: [ :index | 
		self
			setSelectionStateFor: index
			at: (newSelections includes: (self listItems at: index)) ].
	self widget ifNotNil: [ :w | w widget ifNotNil: #changed ]
]

{ #category : #'*Golap-UI' }
MultiColumnListPresenter >> unselectAll [
	"1 to: self listItems size do: [ :index | self setSelectionStateFor: index at: false ].
	self widget ifNotNil: [ :w | w widget ifNotNil: #changed ]"
]
