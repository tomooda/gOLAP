Extension { #name : #TabManagerPresenter }

{ #category : #'*Golap-UI' }
TabManagerPresenter >> eventKeyStrokesForNextFocus [
	"String describing the keystroke to perform to jump to the next widget"

	^ {Character tab asKeyCombination}
]

{ #category : #'*Golap-UI' }
TabManagerPresenter >> eventKeyStrokesForPreviousFocus [
	"String describing the keystroke to perform to jump to the next widget"

	^ {Character tab shift asKeyCombination}
]
