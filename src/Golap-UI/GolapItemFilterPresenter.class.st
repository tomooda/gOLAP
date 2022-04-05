Class {
	#name : #GolapItemFilterPresenter,
	#superclass : #GolapFilterPresenter,
	#category : #'Golap-UI-Query'
}

{ #category : #accessing }
GolapItemFilterPresenter >> filterSpec [
	^ self query itemFilterSpec
]
