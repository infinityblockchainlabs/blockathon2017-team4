'use strict';
const globals = require('../../server/boot/globals');
const async = require('async');
const _ = require('underscore');

module.exports = function(PayLoan) {
  //PayLoan.disableRemoteMethodByName('create');
  PayLoan.disableRemoteMethodByName('count');
  PayLoan.disableRemoteMethodByName('destroyById');
  PayLoan.disableRemoteMethodByName('destroyAll');
  PayLoan.disableRemoteMethodByName('findOne');
  PayLoan.disableRemoteMethodByName('updateAll');
  PayLoan.disableRemoteMethodByName('upsert');
  PayLoan.disableRemoteMethodByName('upsertWithWhere');
  PayLoan.disableRemoteMethodByName('replaceById');
  PayLoan.disableRemoteMethodByName('replaceOrCreate');
  PayLoan.disableRemoteMethodByName('findOrCreate');
  PayLoan.disableRemoteMethodByName('updateAttribute');
  PayLoan.disableRemoteMethodByName('updateAttributes');
  PayLoan.disableRemoteMethodByName('destroy');
  PayLoan.disableRemoteMethodByName('replaceAttributes');
  PayLoan.disableRemoteMethodByName('createChangeStream');
  PayLoan.disableRemoteMethodByName('prototype.patchAttributes');

  //PayLoan.disableRemoteMethodByName('find');
  PayLoan.disableRemoteMethodByName('findById');
  PayLoan.disableRemoteMethodByName('replaceById');
  PayLoan.disableRemoteMethodByName('exists');

  PayLoan.observe('before save', function updateTimestamp(ctx, next) {
    if (ctx.instance) {
      if (!ctx.instance.id) {
        ctx.instance.created = Math.floor(Date.now() / 1000);
      }
      ctx.instance.modified = Math.floor(Date.now() / 1000);
      if (!_.isEmpty(ctx.currentInstance) && !_.isEmpty(ctx.currentInstance.created) && !_.isEmpty(ctx.instance.created)) {
        ctx.instance.created = ctx.currentInstance.created;
      }
    } else {
      ctx.data.modified = Math.floor(Date.now() / 1000);
      if (!_.isEmpty(ctx.currentInstance) && (ctx.currentInstance.created) && (ctx.data.created)) {
        ctx.data.created = ctx.currentInstance.created;
      }
    }
    next();
  });
};