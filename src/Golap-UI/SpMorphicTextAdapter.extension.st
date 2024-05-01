Extension { #name : 'SpMorphicTextAdapter' }

{ #category : '*Golap-UI' }
SpMorphicTextAdapter >> buildWidget [
	| newWidget |
	
	newWidget := (SpRubScrolledTextMorph on: self)
		getTextSelector: #getText;
		setTextSelector: #accept:notifying:;
		getSelectionSelector: #readSelection;
		menuProvider: self selector: #codePaneMenu:shifted:;
		setSelectionSelector: #setSelection:;
		ghostText: self placeholder;
		beWrapped;
		enabled: self enabled;
		askBeforeDiscardingEdits: self askBeforeDiscardingEdits;
		autoAccept: true;
		vResizing: #spaceFill;
		hResizing: #spaceFill;
		setBalloonText: self help;
		dragEnabled: self dragEnabled;
		dropEnabled: self dropEnabled;
		registerScrollChanges: #scrollValueChanged:;
		hScrollbarShowWhenNeeded;
		borderColor: (self borderColor ifNil: [Color gray]);
		borderWidth: (self borderWidth ifNil: [0]);
		yourself.
	
	self setEditable: self presenter isEditable to: newWidget.
	self setEditingModeFor: newWidget.
	self setText: self presenter text to: newWidget.
	self presenter selectionInterval 
		ifNotNil: [  :anInterval | self selectionInterval: anInterval on: newWidget ].

	self setWrapWord: self presenter isWrapWord to: newWidget.	
	self setUndoRedo: self presenter hasUndoRedoHistory to: newWidget. 
	self presenter whenTextChangedDo: [ :text | 
		self setText: text to: newWidget ].
	self presenter whenSelectionChangedDo: [ :selectionInterval | 
		self selectionInterval: selectionInterval ].
	self presenter whenPlaceholderChangedDo: [ :text | 
		self setGhostText: text to: newWidget ].
	self presenter whenEditableChangedDo: [ :value | 
		self setEditable: value to: newWidget ].
	self presenter whenWrapWordChangedDo: [ :value | 
		self setWrapWord: value to: newWidget ].
	
	^ newWidget
]
