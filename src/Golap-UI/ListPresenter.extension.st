Extension { #name : #ListPresenter }

{ #category : #'*Golap-UI' }
ListPresenter >> filteringBlockChanged [
	filteringBlockHolder valueChanged
]

{ #category : #'*Golap-UI' }
ListPresenter >> listHolder [
	^ listHolder
]

{ #category : #'*Golap-UI' }
ListPresenter >> selectedItem: anItem [
	self selectedItem = anItem
		ifFalse: [ self setSelectedItem: anItem ]
]
