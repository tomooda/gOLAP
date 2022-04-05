Extension { #name : #DropListPresenter }

{ #category : #'*Golap-UI' }
DropListPresenter >> selectedItem [
	"<api: #inspect>"

	^ self selectedItemHolder value ifNotNil: #model
]

{ #category : #'*Golap-UI' }
DropListPresenter >> selectedItem: anItem [
	self selectedItem = anItem
		ifFalse: [ self setSelectedItem: anItem ]
]
