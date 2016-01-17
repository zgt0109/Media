class RenameTableQrcodeChannelsToQrcodeChannels < ActiveRecord::Migration
  def change
    rename_table :channel_qrcodes, :qrcode_channels
    rename_table :channel_types, :qrcode_channel_types

    rename_column :qrcode_channels, :channel_type_id, :qrcode_channel_type_id
  end
end
