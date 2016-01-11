class VipImportingLog < ActiveRecord::Base
  belongs_to :site
  enum_attr :error_type, in: [
    ['synced', -1, '同步成功'],
    ['success', 0, '导入成功'],
    ['failed',  1, '导入失败']
  ]
end
