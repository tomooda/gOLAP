Extension { #name : 'SpMorphicTextInputFieldAdapter' }

{ #category : '*Golap-UI' }
SpMorphicTextInputFieldAdapter >> buildWidget [
	| newWidget |

	newWidget := (SpRubTextFieldMorph on: self)
		getTextSelector: #getText;
		setTextSelector: #accept:notifying:;
		getSelectionSelector: #readSelection;
		menuProvider: self selector: #codePaneMenu:shifted:;
		setSelectionSelector: #setSelection:;
		entryCompletion: self entryCompletion;
		ghostText: self getPlaceholderText;
		encrypted: self encrypted;
		enabled: self enabled;
		askBeforeDiscardingEdits: self askBeforeDiscardingEdits;
		autoAccept: true;
		vResizing: #spaceFill;
		hResizing: #spaceFill;
		setBalloonText: self help;
		dragEnabled: self dragEnabled;
		dropEnabled: self dropEnabled;
		maxLength: self presenter maxLength;
		borderColor: (self borderColor ifNil: [Color gray]);
		borderWidth: (self borderWidth ifNil: [0]);
		yourself.

	self presenter selectionInterval 
		ifNotNil: [  :anInterval | self selectionInterval: anInterval on: newWidget ].

	self presenter whenTextChangedDo: [ :text | newWidget setText: text ].
	self presenter whenSelectionChangedDo: [ :selectionInterval | 
		self selectionInterval: selectionInterval ].
	self presenter whenPlaceholderChangedDo: [ :text | 
		newWidget ghostText: (text ifNotNil: [ :aString | 
			aString localizedForPresenter: self presenter ]) ].
	self presenter whenPasswordChangedDo: [ :isPassword | 
		newWidget encrypted: isPassword ].
	self presenter whenMaxLengthChangedDo: [ :length | 
		newWidget maxLength: length ].
	self presenter whenEditableChangedDo: [ :value | 
		self setEditable: value to: newWidget ].

	^ newWidget
]
