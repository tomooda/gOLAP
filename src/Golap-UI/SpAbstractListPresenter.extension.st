Extension { #name : 'SpAbstractListPresenter' }

{ #category : '*Golap-UI' }
SpAbstractListPresenter >> items: aCollection selectItem: anObject [

	self model collection: aCollection.
	self selection selectItem: anObject
]

{ #category : '*Golap-UI' }
SpAbstractListPresenter >> items: aCollection selectItems: anotherCollection [

	self model collection: aCollection.
	self selection selectItems: anotherCollection
]
