Extension { #name : 'SpDropListPresenter' }

{ #category : '*Golap-UI' }
SpDropListPresenter >> items: aCollection selectItem: anObject [

	| realItem |
	self setCollection: aCollection.
	realItem := model collection detect: [ :each | each model = anObject ].
	self selection selectItem: realItem
]
