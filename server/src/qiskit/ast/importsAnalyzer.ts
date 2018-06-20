/**
 * @license
 *
 * Copyright (c) 2018, IBM.
 *
 * This source code is licensed under the Apache License, Version 2.0 found in
 * the LICENSE.txt file in the root directory of this source tree.
 */

import { ParserRuleContext } from 'antlr4ts';
import { AbstractParseTreeVisitor } from 'antlr4ts/tree';
import { Python3Visitor } from '../antlr/Python3Visitor';
import { Import_as_nameContext, AtomContext } from '../antlr/Python3Parser';
import { ErrorBuilder } from '../../tools/errorBuilder';
import { QiskitSDK } from '../compiler/qiskitSymbolTable';
import { ErrorMessages } from '../compiler/tools/errorMessages';
import { PositionAdapter } from '../../tools/positionAdapter';
import { ErrorListener } from '../../tools/errorListener';

export namespace ImportsAnalyzer {
    export function analyze(tree: ParserRuleContext, errorListener: ErrorListener) {
        let validator = new ImportsValidator(errorListener);
        tree.accept(validator);
    }
}

class ImportsValidator extends AbstractParseTreeVisitor<void> implements Python3Visitor<void> {
    imported: String[] = [];
    qiskitSymbols: QiskitSDK;

    constructor(private errorListener: ErrorListener) {
        super();
        this.qiskitSymbols = require('../libs/qiskitSDK.json');
    }

    defaultResult() {}

    visitImport_as_name(ctx: Import_as_nameContext) {
        this.imported.push(ctx.text);
    }

    visitAtom(ctx: AtomContext) {
        let isFromQiskit = this.qiskitSymbols.classes.find(theClass => theClass.name === ctx.text);
        let isPreviouslyImported = this.imported.find(importedValue => importedValue === ctx.text);

        if (isFromQiskit && !isPreviouslyImported) {
            let message = ErrorMessages.notPreviouslyImported(ctx.text);
            let position = PositionAdapter.fromToken(ctx._start);
            let error = ErrorBuilder.warning(message, position);

            this.errorListener.addError(error);
        }
    }
}
