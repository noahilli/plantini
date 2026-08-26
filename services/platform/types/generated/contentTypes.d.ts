import type { Schema, Attribute } from '@strapi/strapi';

export interface AdminPermission extends Schema.CollectionType {
  collectionName: 'admin_permissions';
  info: {
    name: 'Permission';
    description: '';
    singularName: 'permission';
    pluralName: 'permissions';
    displayName: 'Permission';
  };
  pluginOptions: {
    'content-manager': {
      visible: false;
    };
    'content-type-builder': {
      visible: false;
    };
  };
  attributes: {
    action: Attribute.String &
      Attribute.Required &
      Attribute.SetMinMaxLength<{
        minLength: 1;
      }>;
    actionParameters: Attribute.JSON & Attribute.DefaultTo<{}>;
    subject: Attribute.String &
      Attribute.SetMinMaxLength<{
        minLength: 1;
      }>;
    properties: Attribute.JSON & Attribute.DefaultTo<{}>;
    conditions: Attribute.JSON & Attribute.DefaultTo<[]>;
    role: Attribute.Relation<'admin::permission', 'manyToOne', 'admin::role'>;
    createdAt: Attribute.DateTime;
    updatedAt: Attribute.DateTime;
    createdBy: Attribute.Relation<
      'admin::permission',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
    updatedBy: Attribute.Relation<
      'admin::permission',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
  };
}

export interface AdminUser extends Schema.CollectionType {
  collectionName: 'admin_users';
  info: {
    name: 'User';
    description: '';
    singularName: 'user';
    pluralName: 'users';
    displayName: 'User';
  };
  pluginOptions: {
    'content-manager': {
      visible: false;
    };
    'content-type-builder': {
      visible: false;
    };
  };
  attributes: {
    firstname: Attribute.String &
      Attribute.SetMinMaxLength<{
        minLength: 1;
      }>;
    lastname: Attribute.String &
      Attribute.SetMinMaxLength<{
        minLength: 1;
      }>;
    username: Attribute.String;
    email: Attribute.Email &
      Attribute.Required &
      Attribute.Private &
      Attribute.Unique &
      Attribute.SetMinMaxLength<{
        minLength: 6;
      }>;
    password: Attribute.Password &
      Attribute.Private &
      Attribute.SetMinMaxLength<{
        minLength: 6;
      }>;
    resetPasswordToken: Attribute.String & Attribute.Private;
    registrationToken: Attribute.String & Attribute.Private;
    isActive: Attribute.Boolean &
      Attribute.Private &
      Attribute.DefaultTo<false>;
    roles: Attribute.Relation<'admin::user', 'manyToMany', 'admin::role'> &
      Attribute.Private;
    blocked: Attribute.Boolean & Attribute.Private & Attribute.DefaultTo<false>;
    preferedLanguage: Attribute.String;
    createdAt: Attribute.DateTime;
    updatedAt: Attribute.DateTime;
    createdBy: Attribute.Relation<'admin::user', 'oneToOne', 'admin::user'> &
      Attribute.Private;
    updatedBy: Attribute.Relation<'admin::user', 'oneToOne', 'admin::user'> &
      Attribute.Private;
  };
}

export interface AdminRole extends Schema.CollectionType {
  collectionName: 'admin_roles';
  info: {
    name: 'Role';
    description: '';
    singularName: 'role';
    pluralName: 'roles';
    displayName: 'Role';
  };
  pluginOptions: {
    'content-manager': {
      visible: false;
    };
    'content-type-builder': {
      visible: false;
    };
  };
  attributes: {
    name: Attribute.String &
      Attribute.Required &
      Attribute.Unique &
      Attribute.SetMinMaxLength<{
        minLength: 1;
      }>;
    code: Attribute.String &
      Attribute.Required &
      Attribute.Unique &
      Attribute.SetMinMaxLength<{
        minLength: 1;
      }>;
    description: Attribute.String;
    users: Attribute.Relation<'admin::role', 'manyToMany', 'admin::user'>;
    permissions: Attribute.Relation<
      'admin::role',
      'oneToMany',
      'admin::permission'
    >;
    createdAt: Attribute.DateTime;
    updatedAt: Attribute.DateTime;
    createdBy: Attribute.Relation<'admin::role', 'oneToOne', 'admin::user'> &
      Attribute.Private;
    updatedBy: Attribute.Relation<'admin::role', 'oneToOne', 'admin::user'> &
      Attribute.Private;
  };
}

export interface AdminApiToken extends Schema.CollectionType {
  collectionName: 'strapi_api_tokens';
  info: {
    name: 'Api Token';
    singularName: 'api-token';
    pluralName: 'api-tokens';
    displayName: 'Api Token';
    description: '';
  };
  pluginOptions: {
    'content-manager': {
      visible: false;
    };
    'content-type-builder': {
      visible: false;
    };
  };
  attributes: {
    name: Attribute.String &
      Attribute.Required &
      Attribute.Unique &
      Attribute.SetMinMaxLength<{
        minLength: 1;
      }>;
    description: Attribute.String &
      Attribute.SetMinMaxLength<{
        minLength: 1;
      }> &
      Attribute.DefaultTo<''>;
    type: Attribute.Enumeration<['read-only', 'full-access', 'custom']> &
      Attribute.Required &
      Attribute.DefaultTo<'read-only'>;
    accessKey: Attribute.String &
      Attribute.Required &
      Attribute.SetMinMaxLength<{
        minLength: 1;
      }>;
    lastUsedAt: Attribute.DateTime;
    permissions: Attribute.Relation<
      'admin::api-token',
      'oneToMany',
      'admin::api-token-permission'
    >;
    expiresAt: Attribute.DateTime;
    lifespan: Attribute.BigInteger;
    createdAt: Attribute.DateTime;
    updatedAt: Attribute.DateTime;
    createdBy: Attribute.Relation<
      'admin::api-token',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
    updatedBy: Attribute.Relation<
      'admin::api-token',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
  };
}

export interface AdminApiTokenPermission extends Schema.CollectionType {
  collectionName: 'strapi_api_token_permissions';
  info: {
    name: 'API Token Permission';
    description: '';
    singularName: 'api-token-permission';
    pluralName: 'api-token-permissions';
    displayName: 'API Token Permission';
  };
  pluginOptions: {
    'content-manager': {
      visible: false;
    };
    'content-type-builder': {
      visible: false;
    };
  };
  attributes: {
    action: Attribute.String &
      Attribute.Required &
      Attribute.SetMinMaxLength<{
        minLength: 1;
      }>;
    token: Attribute.Relation<
      'admin::api-token-permission',
      'manyToOne',
      'admin::api-token'
    >;
    createdAt: Attribute.DateTime;
    updatedAt: Attribute.DateTime;
    createdBy: Attribute.Relation<
      'admin::api-token-permission',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
    updatedBy: Attribute.Relation<
      'admin::api-token-permission',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
  };
}

export interface AdminTransferToken extends Schema.CollectionType {
  collectionName: 'strapi_transfer_tokens';
  info: {
    name: 'Transfer Token';
    singularName: 'transfer-token';
    pluralName: 'transfer-tokens';
    displayName: 'Transfer Token';
    description: '';
  };
  pluginOptions: {
    'content-manager': {
      visible: false;
    };
    'content-type-builder': {
      visible: false;
    };
  };
  attributes: {
    name: Attribute.String &
      Attribute.Required &
      Attribute.Unique &
      Attribute.SetMinMaxLength<{
        minLength: 1;
      }>;
    description: Attribute.String &
      Attribute.SetMinMaxLength<{
        minLength: 1;
      }> &
      Attribute.DefaultTo<''>;
    accessKey: Attribute.String &
      Attribute.Required &
      Attribute.SetMinMaxLength<{
        minLength: 1;
      }>;
    lastUsedAt: Attribute.DateTime;
    permissions: Attribute.Relation<
      'admin::transfer-token',
      'oneToMany',
      'admin::transfer-token-permission'
    >;
    expiresAt: Attribute.DateTime;
    lifespan: Attribute.BigInteger;
    createdAt: Attribute.DateTime;
    updatedAt: Attribute.DateTime;
    createdBy: Attribute.Relation<
      'admin::transfer-token',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
    updatedBy: Attribute.Relation<
      'admin::transfer-token',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
  };
}

export interface AdminTransferTokenPermission extends Schema.CollectionType {
  collectionName: 'strapi_transfer_token_permissions';
  info: {
    name: 'Transfer Token Permission';
    description: '';
    singularName: 'transfer-token-permission';
    pluralName: 'transfer-token-permissions';
    displayName: 'Transfer Token Permission';
  };
  pluginOptions: {
    'content-manager': {
      visible: false;
    };
    'content-type-builder': {
      visible: false;
    };
  };
  attributes: {
    action: Attribute.String &
      Attribute.Required &
      Attribute.SetMinMaxLength<{
        minLength: 1;
      }>;
    token: Attribute.Relation<
      'admin::transfer-token-permission',
      'manyToOne',
      'admin::transfer-token'
    >;
    createdAt: Attribute.DateTime;
    updatedAt: Attribute.DateTime;
    createdBy: Attribute.Relation<
      'admin::transfer-token-permission',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
    updatedBy: Attribute.Relation<
      'admin::transfer-token-permission',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
  };
}

export interface PluginUploadFile extends Schema.CollectionType {
  collectionName: 'files';
  info: {
    singularName: 'file';
    pluralName: 'files';
    displayName: 'File';
    description: '';
  };
  pluginOptions: {
    'content-manager': {
      visible: false;
    };
    'content-type-builder': {
      visible: false;
    };
  };
  attributes: {
    name: Attribute.String & Attribute.Required;
    alternativeText: Attribute.String;
    caption: Attribute.String;
    width: Attribute.Integer;
    height: Attribute.Integer;
    formats: Attribute.JSON;
    hash: Attribute.String & Attribute.Required;
    ext: Attribute.String;
    mime: Attribute.String & Attribute.Required;
    size: Attribute.Decimal & Attribute.Required;
    url: Attribute.String & Attribute.Required;
    previewUrl: Attribute.String;
    provider: Attribute.String & Attribute.Required;
    provider_metadata: Attribute.JSON;
    related: Attribute.Relation<'plugin::upload.file', 'morphToMany'>;
    folder: Attribute.Relation<
      'plugin::upload.file',
      'manyToOne',
      'plugin::upload.folder'
    > &
      Attribute.Private;
    folderPath: Attribute.String &
      Attribute.Required &
      Attribute.Private &
      Attribute.SetMinMax<
        {
          min: 1;
        },
        number
      >;
    createdAt: Attribute.DateTime;
    updatedAt: Attribute.DateTime;
    createdBy: Attribute.Relation<
      'plugin::upload.file',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
    updatedBy: Attribute.Relation<
      'plugin::upload.file',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
  };
}

export interface PluginUploadFolder extends Schema.CollectionType {
  collectionName: 'upload_folders';
  info: {
    singularName: 'folder';
    pluralName: 'folders';
    displayName: 'Folder';
  };
  pluginOptions: {
    'content-manager': {
      visible: false;
    };
    'content-type-builder': {
      visible: false;
    };
  };
  attributes: {
    name: Attribute.String &
      Attribute.Required &
      Attribute.SetMinMax<
        {
          min: 1;
        },
        number
      >;
    pathId: Attribute.Integer & Attribute.Required & Attribute.Unique;
    parent: Attribute.Relation<
      'plugin::upload.folder',
      'manyToOne',
      'plugin::upload.folder'
    >;
    children: Attribute.Relation<
      'plugin::upload.folder',
      'oneToMany',
      'plugin::upload.folder'
    >;
    files: Attribute.Relation<
      'plugin::upload.folder',
      'oneToMany',
      'plugin::upload.file'
    >;
    path: Attribute.String &
      Attribute.Required &
      Attribute.SetMinMax<
        {
          min: 1;
        },
        number
      >;
    createdAt: Attribute.DateTime;
    updatedAt: Attribute.DateTime;
    createdBy: Attribute.Relation<
      'plugin::upload.folder',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
    updatedBy: Attribute.Relation<
      'plugin::upload.folder',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
  };
}

export interface PluginContentReleasesRelease extends Schema.CollectionType {
  collectionName: 'strapi_releases';
  info: {
    singularName: 'release';
    pluralName: 'releases';
    displayName: 'Release';
  };
  options: {
    draftAndPublish: false;
  };
  pluginOptions: {
    'content-manager': {
      visible: false;
    };
    'content-type-builder': {
      visible: false;
    };
  };
  attributes: {
    name: Attribute.String & Attribute.Required;
    releasedAt: Attribute.DateTime;
    scheduledAt: Attribute.DateTime;
    timezone: Attribute.String;
    status: Attribute.Enumeration<
      ['ready', 'blocked', 'failed', 'done', 'empty']
    > &
      Attribute.Required;
    actions: Attribute.Relation<
      'plugin::content-releases.release',
      'oneToMany',
      'plugin::content-releases.release-action'
    >;
    createdAt: Attribute.DateTime;
    updatedAt: Attribute.DateTime;
    createdBy: Attribute.Relation<
      'plugin::content-releases.release',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
    updatedBy: Attribute.Relation<
      'plugin::content-releases.release',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
  };
}

export interface PluginContentReleasesReleaseAction
  extends Schema.CollectionType {
  collectionName: 'strapi_release_actions';
  info: {
    singularName: 'release-action';
    pluralName: 'release-actions';
    displayName: 'Release Action';
  };
  options: {
    draftAndPublish: false;
  };
  pluginOptions: {
    'content-manager': {
      visible: false;
    };
    'content-type-builder': {
      visible: false;
    };
  };
  attributes: {
    type: Attribute.Enumeration<['publish', 'unpublish']> & Attribute.Required;
    entry: Attribute.Relation<
      'plugin::content-releases.release-action',
      'morphToOne'
    >;
    contentType: Attribute.String & Attribute.Required;
    locale: Attribute.String;
    release: Attribute.Relation<
      'plugin::content-releases.release-action',
      'manyToOne',
      'plugin::content-releases.release'
    >;
    isEntryValid: Attribute.Boolean;
    createdAt: Attribute.DateTime;
    updatedAt: Attribute.DateTime;
    createdBy: Attribute.Relation<
      'plugin::content-releases.release-action',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
    updatedBy: Attribute.Relation<
      'plugin::content-releases.release-action',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
  };
}

export interface PluginI18NLocale extends Schema.CollectionType {
  collectionName: 'i18n_locale';
  info: {
    singularName: 'locale';
    pluralName: 'locales';
    collectionName: 'locales';
    displayName: 'Locale';
    description: '';
  };
  options: {
    draftAndPublish: false;
  };
  pluginOptions: {
    'content-manager': {
      visible: false;
    };
    'content-type-builder': {
      visible: false;
    };
  };
  attributes: {
    name: Attribute.String &
      Attribute.SetMinMax<
        {
          min: 1;
          max: 50;
        },
        number
      >;
    code: Attribute.String & Attribute.Unique;
    createdAt: Attribute.DateTime;
    updatedAt: Attribute.DateTime;
    createdBy: Attribute.Relation<
      'plugin::i18n.locale',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
    updatedBy: Attribute.Relation<
      'plugin::i18n.locale',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
  };
}

export interface PluginUsersPermissionsPermission
  extends Schema.CollectionType {
  collectionName: 'up_permissions';
  info: {
    name: 'permission';
    description: '';
    singularName: 'permission';
    pluralName: 'permissions';
    displayName: 'Permission';
  };
  pluginOptions: {
    'content-manager': {
      visible: false;
    };
    'content-type-builder': {
      visible: false;
    };
  };
  attributes: {
    action: Attribute.String & Attribute.Required;
    role: Attribute.Relation<
      'plugin::users-permissions.permission',
      'manyToOne',
      'plugin::users-permissions.role'
    >;
    createdAt: Attribute.DateTime;
    updatedAt: Attribute.DateTime;
    createdBy: Attribute.Relation<
      'plugin::users-permissions.permission',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
    updatedBy: Attribute.Relation<
      'plugin::users-permissions.permission',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
  };
}

export interface PluginUsersPermissionsRole extends Schema.CollectionType {
  collectionName: 'up_roles';
  info: {
    name: 'role';
    description: '';
    singularName: 'role';
    pluralName: 'roles';
    displayName: 'Role';
  };
  pluginOptions: {
    'content-manager': {
      visible: false;
    };
    'content-type-builder': {
      visible: false;
    };
  };
  attributes: {
    name: Attribute.String &
      Attribute.Required &
      Attribute.SetMinMaxLength<{
        minLength: 3;
      }>;
    description: Attribute.String;
    type: Attribute.String & Attribute.Unique;
    permissions: Attribute.Relation<
      'plugin::users-permissions.role',
      'oneToMany',
      'plugin::users-permissions.permission'
    >;
    users: Attribute.Relation<
      'plugin::users-permissions.role',
      'oneToMany',
      'plugin::users-permissions.user'
    >;
    createdAt: Attribute.DateTime;
    updatedAt: Attribute.DateTime;
    createdBy: Attribute.Relation<
      'plugin::users-permissions.role',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
    updatedBy: Attribute.Relation<
      'plugin::users-permissions.role',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
  };
}

export interface PluginUsersPermissionsUser extends Schema.CollectionType {
  collectionName: 'up_users';
  info: {
    name: 'user';
    description: '';
    singularName: 'user';
    pluralName: 'users';
    displayName: 'User';
  };
  options: {
    draftAndPublish: false;
    timestamps: true;
  };
  attributes: {
    username: Attribute.String &
      Attribute.Required &
      Attribute.Unique &
      Attribute.SetMinMaxLength<{
        minLength: 3;
      }>;
    email: Attribute.Email &
      Attribute.Required &
      Attribute.SetMinMaxLength<{
        minLength: 6;
      }>;
    provider: Attribute.String;
    password: Attribute.Password &
      Attribute.Private &
      Attribute.SetMinMaxLength<{
        minLength: 6;
      }>;
    resetPasswordToken: Attribute.String & Attribute.Private;
    confirmationToken: Attribute.String & Attribute.Private;
    confirmed: Attribute.Boolean & Attribute.DefaultTo<false>;
    blocked: Attribute.Boolean & Attribute.DefaultTo<false>;
    role: Attribute.Relation<
      'plugin::users-permissions.user',
      'manyToOne',
      'plugin::users-permissions.role'
    >;
    createdAt: Attribute.DateTime;
    updatedAt: Attribute.DateTime;
    createdBy: Attribute.Relation<
      'plugin::users-permissions.user',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
    updatedBy: Attribute.Relation<
      'plugin::users-permissions.user',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
  };
}

export interface ApiContentReleaseContentRelease extends Schema.CollectionType {
  collectionName: 'content_releases';
  info: {
    singularName: 'content-release';
    pluralName: 'content-releases';
    displayName: 'Content Release';
  };
  options: {
    draftAndPublish: true;
  };
  attributes: {
    version: Attribute.String & Attribute.Required & Attribute.Unique;
    active: Attribute.Boolean & Attribute.Required & Attribute.DefaultTo<false>;
    manifest: Attribute.JSON & Attribute.Required;
    cursor: Attribute.String & Attribute.Required & Attribute.Unique;
    changes: Attribute.JSON & Attribute.DefaultTo<[]>;
    createdAt: Attribute.DateTime;
    updatedAt: Attribute.DateTime;
    publishedAt: Attribute.DateTime;
    createdBy: Attribute.Relation<
      'api::content-release.content-release',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
    updatedBy: Attribute.Relation<
      'api::content-release.content-release',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
  };
}

export interface ApiEcosystemEcosystem extends Schema.CollectionType {
  collectionName: 'ecosystems';
  info: {
    singularName: 'ecosystem';
    pluralName: 'ecosystems';
    displayName: 'Ecosystem';
  };
  options: {
    draftAndPublish: true;
  };
  attributes: {
    publicId: Attribute.String & Attribute.Required & Attribute.Unique;
    slug: Attribute.String & Attribute.Required & Attribute.Unique;
    releaseVersion: Attribute.String & Attribute.Required;
    name: Attribute.String & Attribute.Required;
    description: Attribute.Text;
    climateZone: Attribute.String;
    region: Attribute.String;
    season: Attribute.String;
    language: Attribute.String & Attribute.DefaultTo<'de'>;
    levels: Attribute.Relation<
      'api::ecosystem.ecosystem',
      'oneToMany',
      'api::level.level'
    >;
    createdAt: Attribute.DateTime;
    updatedAt: Attribute.DateTime;
    publishedAt: Attribute.DateTime;
    createdBy: Attribute.Relation<
      'api::ecosystem.ecosystem',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
    updatedBy: Attribute.Relation<
      'api::ecosystem.ecosystem',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
  };
}

export interface ApiIdentificationJobIdentificationJob
  extends Schema.CollectionType {
  collectionName: 'identification_jobs';
  info: {
    singularName: 'identification-job';
    pluralName: 'identification-jobs';
    displayName: 'Identification Job';
  };
  options: {
    draftAndPublish: false;
  };
  attributes: {
    publicId: Attribute.String & Attribute.Required & Attribute.Unique;
    ownerId: Attribute.String & Attribute.Required;
    clientJobId: Attribute.String & Attribute.Required;
    ownerClientJobKey: Attribute.String & Attribute.Required & Attribute.Unique;
    idempotencyKey: Attribute.String & Attribute.Required & Attribute.Unique;
    requestDigest: Attribute.String & Attribute.Required;
    mediaId: Attribute.String & Attribute.Required;
    expectedPlantId: Attribute.String;
    confirmedPlantId: Attribute.String;
    confirmedCandidateId: Attribute.String;
    status: Attribute.Enumeration<
      ['pending', 'processing', 'identified', 'failed', 'cancelled']
    > &
      Attribute.Required;
    attempts: Attribute.Integer & Attribute.Required & Attribute.DefaultTo<0>;
    retryAfter: Attribute.DateTime;
    candidates: Attribute.JSON & Attribute.DefaultTo<[]>;
    failureCode: Attribute.String;
    providerMetadata: Attribute.JSON;
    createdAt: Attribute.DateTime;
    updatedAt: Attribute.DateTime;
    createdBy: Attribute.Relation<
      'api::identification-job.identification-job',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
    updatedBy: Attribute.Relation<
      'api::identification-job.identification-job',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
  };
}

export interface ApiLearningEventLearningEvent extends Schema.CollectionType {
  collectionName: 'learning_events';
  info: {
    singularName: 'learning-event';
    pluralName: 'learning-events';
    displayName: 'Learning Event';
  };
  options: {
    draftAndPublish: false;
  };
  attributes: {
    publicId: Attribute.String & Attribute.Required & Attribute.Unique;
    ownerId: Attribute.String & Attribute.Required;
    clientEventId: Attribute.String & Attribute.Required;
    idempotencyKey: Attribute.String & Attribute.Required & Attribute.Unique;
    requestDigest: Attribute.String & Attribute.Required;
    type: Attribute.String & Attribute.Required;
    occurredAt: Attribute.DateTime & Attribute.Required;
    payloadVersion: Attribute.Integer & Attribute.Required;
    payload: Attribute.JSON & Attribute.Required;
    receivedAt: Attribute.DateTime & Attribute.Required;
    createdAt: Attribute.DateTime;
    updatedAt: Attribute.DateTime;
    createdBy: Attribute.Relation<
      'api::learning-event.learning-event',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
    updatedBy: Attribute.Relation<
      'api::learning-event.learning-event',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
  };
}

export interface ApiLevelLevel extends Schema.CollectionType {
  collectionName: 'levels';
  info: {
    singularName: 'level';
    pluralName: 'levels';
    displayName: 'Level';
  };
  options: {
    draftAndPublish: true;
  };
  attributes: {
    publicId: Attribute.String & Attribute.Required & Attribute.Unique;
    slug: Attribute.String & Attribute.Required & Attribute.Unique;
    releaseVersion: Attribute.String & Attribute.Required;
    title: Attribute.String & Attribute.Required;
    levelNumber: Attribute.Integer & Attribute.Required;
    sequence: Attribute.Integer & Attribute.Required;
    difficulty: Attribute.String;
    learningGoal: Attribute.Text;
    completionRule: Attribute.JSON & Attribute.Required;
    plants: Attribute.Relation<
      'api::level.level',
      'manyToMany',
      'api::plant.plant'
    >;
    quizzes: Attribute.Relation<
      'api::level.level',
      'oneToMany',
      'api::quiz.quiz'
    >;
    ecosystem: Attribute.Relation<
      'api::level.level',
      'manyToOne',
      'api::ecosystem.ecosystem'
    >;
    createdAt: Attribute.DateTime;
    updatedAt: Attribute.DateTime;
    publishedAt: Attribute.DateTime;
    createdBy: Attribute.Relation<
      'api::level.level',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
    updatedBy: Attribute.Relation<
      'api::level.level',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
  };
}

export interface ApiLevelAttemptLevelAttempt extends Schema.CollectionType {
  collectionName: 'level_attempts';
  info: {
    singularName: 'level-attempt';
    pluralName: 'level-attempts';
    displayName: 'Level Attempt';
  };
  options: {
    draftAndPublish: false;
  };
  attributes: {
    publicId: Attribute.String & Attribute.Required & Attribute.Unique;
    ownerId: Attribute.String & Attribute.Required;
    clientAttemptId: Attribute.String & Attribute.Required;
    ownerClientAttemptKey: Attribute.String &
      Attribute.Required &
      Attribute.Unique;
    idempotencyKey: Attribute.String & Attribute.Required & Attribute.Unique;
    requestDigest: Attribute.String & Attribute.Required;
    levelPublicId: Attribute.String & Attribute.Required;
    contentVersion: Attribute.String & Attribute.Required;
    status: Attribute.Enumeration<['active', 'completed', 'expired']> &
      Attribute.Required;
    startedAt: Attribute.DateTime & Attribute.Required;
    completedAt: Attribute.DateTime;
    completionIdempotencyKey: Attribute.String & Attribute.Unique;
    completionDigest: Attribute.String;
    completionClientEventId: Attribute.String;
    score: Attribute.Decimal;
    passed: Attribute.Boolean;
    progress: Attribute.Decimal;
    createdAt: Attribute.DateTime;
    updatedAt: Attribute.DateTime;
    createdBy: Attribute.Relation<
      'api::level-attempt.level-attempt',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
    updatedBy: Attribute.Relation<
      'api::level-attempt.level-attempt',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
  };
}

export interface ApiMediaMedia extends Schema.CollectionType {
  collectionName: 'medias';
  info: {
    singularName: 'media';
    pluralName: 'medias';
    displayName: 'Media';
  };
  options: {
    draftAndPublish: true;
  };
  attributes: {
    publicId: Attribute.String & Attribute.Required & Attribute.Unique;
    slug: Attribute.String & Attribute.Required & Attribute.Unique;
    releaseVersion: Attribute.String & Attribute.Required;
    title: Attribute.String & Attribute.Required;
    file: Attribute.Media<'images' | 'files' | 'videos' | 'audios'> &
      Attribute.Required;
    caption: Attribute.Text;
    license: Attribute.String & Attribute.Required;
    author: Attribute.String & Attribute.Required;
    plant: Attribute.Relation<
      'api::media.media',
      'manyToOne',
      'api::plant.plant'
    >;
    altText: Attribute.String & Attribute.Required;
    source: Attribute.String;
    createdAt: Attribute.DateTime;
    updatedAt: Attribute.DateTime;
    publishedAt: Attribute.DateTime;
    createdBy: Attribute.Relation<
      'api::media.media',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
    updatedBy: Attribute.Relation<
      'api::media.media',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
  };
}

export interface ApiObservationObservation extends Schema.CollectionType {
  collectionName: 'observations';
  info: {
    singularName: 'observation';
    pluralName: 'observations';
    displayName: 'Observation';
    description: 'Herbarium entry / Observation';
  };
  options: {
    draftAndPublish: false;
  };
  attributes: {
    publicId: Attribute.String & Attribute.Required & Attribute.Unique;
    ownerId: Attribute.String & Attribute.Required;
    clientObservationId: Attribute.String & Attribute.Required;
    ownerClientObservationKey: Attribute.String &
      Attribute.Required &
      Attribute.Unique;
    idempotencyKey: Attribute.String & Attribute.Required & Attribute.Unique;
    requestDigest: Attribute.String & Attribute.Required;
    version: Attribute.String & Attribute.Required;
    syncStatus: Attribute.Enumeration<
      ['synced', 'pending', 'conflict', 'deleted']
    > &
      Attribute.Required &
      Attribute.DefaultTo<'synced'>;
    photo: Attribute.Relation<
      'api::observation.observation',
      'oneToOne',
      'api::media.media'
    >;
    mediaId: Attribute.String;
    latitude: Attribute.Decimal;
    longitude: Attribute.Decimal;
    locationAccuracyMeters: Attribute.Decimal;
    timestamp: Attribute.DateTime & Attribute.Required;
    notes: Attribute.Text;
    plantnetScores: Attribute.JSON;
    identificationJobId: Attribute.String;
    confirmedPlantId: Attribute.String;
    deletedAt: Attribute.DateTime;
    plant: Attribute.Relation<
      'api::observation.observation',
      'manyToOne',
      'api::plant.plant'
    >;
    organisationId: Attribute.String;
    createdAt: Attribute.DateTime;
    updatedAt: Attribute.DateTime;
    createdBy: Attribute.Relation<
      'api::observation.observation',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
    updatedBy: Attribute.Relation<
      'api::observation.observation',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
  };
}

export interface ApiPlantPlant extends Schema.CollectionType {
  collectionName: 'plants';
  info: {
    singularName: 'plant';
    pluralName: 'plants';
    displayName: 'Plant';
  };
  options: {
    draftAndPublish: true;
  };
  attributes: {
    publicId: Attribute.String & Attribute.Required & Attribute.Unique;
    slug: Attribute.String & Attribute.Required & Attribute.Unique;
    releaseVersion: Attribute.String & Attribute.Required;
    scientificName: Attribute.String & Attribute.Required;
    commonName: Attribute.String;
    family: Attribute.String;
    description: Attribute.Text;
    warning: Attribute.Text;
    sources: Attribute.JSON & Attribute.DefaultTo<[]>;
    features: Attribute.JSON & Attribute.DefaultTo<[]>;
    media: Attribute.Relation<
      'api::plant.plant',
      'oneToMany',
      'api::media.media'
    >;
    levels: Attribute.Relation<
      'api::plant.plant',
      'manyToMany',
      'api::level.level'
    >;
    reviewStatus: Attribute.Enumeration<
      ['draft', 'pending_review', 'approved', 'rejected']
    > &
      Attribute.DefaultTo<'draft'>;
    kingdom: Attribute.String;
    order: Attribute.String;
    genus: Attribute.String;
    species: Attribute.String;
    createdAt: Attribute.DateTime;
    updatedAt: Attribute.DateTime;
    publishedAt: Attribute.DateTime;
    createdBy: Attribute.Relation<
      'api::plant.plant',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
    updatedBy: Attribute.Relation<
      'api::plant.plant',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
  };
}

export interface ApiPrivateMediaPrivateMedia extends Schema.CollectionType {
  collectionName: 'private_media';
  info: {
    singularName: 'private-media';
    pluralName: 'private-medias';
    displayName: 'Private Media';
  };
  options: {
    draftAndPublish: false;
  };
  attributes: {
    publicId: Attribute.String & Attribute.Required & Attribute.Unique;
    ownerId: Attribute.String & Attribute.Required;
    clientMediaId: Attribute.String & Attribute.Required;
    ownerClientMediaKey: Attribute.String &
      Attribute.Required &
      Attribute.Unique;
    idempotencyKey: Attribute.String & Attribute.Required & Attribute.Unique;
    requestDigest: Attribute.String & Attribute.Required;
    contentType: Attribute.String & Attribute.Required;
    bytes: Attribute.Integer & Attribute.Required;
    status: Attribute.Enumeration<
      ['reserved', 'uploaded', 'rejected', 'deleted']
    > &
      Attribute.Required;
    expiresAt: Attribute.DateTime & Attribute.Required;
    sha256: Attribute.String;
    storageKey: Attribute.String;
    createdAt: Attribute.DateTime;
    updatedAt: Attribute.DateTime;
    createdBy: Attribute.Relation<
      'api::private-media.private-media',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
    updatedBy: Attribute.Relation<
      'api::private-media.private-media',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
  };
}

export interface ApiProfileProfile extends Schema.CollectionType {
  collectionName: 'plantini_profiles';
  info: {
    singularName: 'profile';
    pluralName: 'profiles';
    displayName: 'Plantini Profile';
    description: 'Internal profile mapped one-to-one to a Keycloak subject.';
  };
  options: {
    draftAndPublish: false;
  };
  attributes: {
    profileId: Attribute.String & Attribute.Required & Attribute.Unique;
    keycloakSubject: Attribute.String & Attribute.Required & Attribute.Unique;
    displayName: Attribute.String & Attribute.Required;
    locale: Attribute.String &
      Attribute.Required &
      Attribute.DefaultTo<'de-DE'>;
    organisationId: Attribute.String;
    status: Attribute.Enumeration<
      ['active', 'suspended', 'deletion_requested']
    > &
      Attribute.Required &
      Attribute.DefaultTo<'active'>;
    createdAt: Attribute.DateTime;
    updatedAt: Attribute.DateTime;
    createdBy: Attribute.Relation<
      'api::profile.profile',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
    updatedBy: Attribute.Relation<
      'api::profile.profile',
      'oneToOne',
      'admin::user'
    > &
      Attribute.Private;
  };
}

export interface ApiQuizQuiz extends Schema.CollectionType {
  collectionName: 'quizzes';
  info: {
    singularName: 'quiz';
    pluralName: 'quizzes';
    displayName: 'Quiz';
  };
  options: {
    draftAndPublish: true;
  };
  attributes: {
    publicId: Attribute.String & Attribute.Required & Attribute.Unique;
    slug: Attribute.String & Attribute.Required & Attribute.Unique;
    releaseVersion: Attribute.String & Attribute.Required;
    contentVersion: Attribute.String & Attribute.Required;
    title: Attribute.String & Attribute.Required;
    quizType: Attribute.Enumeration<
      ['multiple-choice', 'flashcard', 'identification', 'feature-match']
    >;
    data: Attribute.JSON;
    level: Attribute.Relation<
      'api::quiz.quiz',
      'manyToOne',
      'api::level.level'
    >;
    plant: Attribute.Relation<
      'api::quiz.quiz',
      'manyToOne',
      'api::plant.plant'
    >;
    reviewStatus: Attribute.Enumeration<
      ['draft', 'pending_review', 'approved', 'rejected']
    > &
      Attribute.DefaultTo<'draft'>;
    createdAt: Attribute.DateTime;
    updatedAt: Attribute.DateTime;
    publishedAt: Attribute.DateTime;
    createdBy: Attribute.Relation<'api::quiz.quiz', 'oneToOne', 'admin::user'> &
      Attribute.Private;
    updatedBy: Attribute.Relation<'api::quiz.quiz', 'oneToOne', 'admin::user'> &
      Attribute.Private;
  };
}

declare module '@strapi/types' {
  export module Shared {
    export interface ContentTypes {
      'admin::permission': AdminPermission;
      'admin::user': AdminUser;
      'admin::role': AdminRole;
      'admin::api-token': AdminApiToken;
      'admin::api-token-permission': AdminApiTokenPermission;
      'admin::transfer-token': AdminTransferToken;
      'admin::transfer-token-permission': AdminTransferTokenPermission;
      'plugin::upload.file': PluginUploadFile;
      'plugin::upload.folder': PluginUploadFolder;
      'plugin::content-releases.release': PluginContentReleasesRelease;
      'plugin::content-releases.release-action': PluginContentReleasesReleaseAction;
      'plugin::i18n.locale': PluginI18NLocale;
      'plugin::users-permissions.permission': PluginUsersPermissionsPermission;
      'plugin::users-permissions.role': PluginUsersPermissionsRole;
      'plugin::users-permissions.user': PluginUsersPermissionsUser;
      'api::content-release.content-release': ApiContentReleaseContentRelease;
      'api::ecosystem.ecosystem': ApiEcosystemEcosystem;
      'api::identification-job.identification-job': ApiIdentificationJobIdentificationJob;
      'api::learning-event.learning-event': ApiLearningEventLearningEvent;
      'api::level.level': ApiLevelLevel;
      'api::level-attempt.level-attempt': ApiLevelAttemptLevelAttempt;
      'api::media.media': ApiMediaMedia;
      'api::observation.observation': ApiObservationObservation;
      'api::plant.plant': ApiPlantPlant;
      'api::private-media.private-media': ApiPrivateMediaPrivateMedia;
      'api::profile.profile': ApiProfileProfile;
      'api::quiz.quiz': ApiQuizQuiz;
    }
  }
}
