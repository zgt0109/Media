/**
 * Created by Administrator on 14-3-29.
 */
Validate = function () {

    var validate_vwebsite = function () {
        $('#form-1').validate({
            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                name: {
                    required: true,
                    minlength: 8
                },
                replyKeywords: {
                    required: true
                }
            },
            messages: {
                name: {
                    required: "请填写信息",
                    minlength: "长度不够"
                },
                replyKeywords: "请填写信息"
            },
            highlight: function (e) {
                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        })
    }
    var validateVwebsiteMenus = function () {
        $('#form-1').validate({
            errorElement: 'span',
            errorClass: 'help-block',
            rules: {
                sort: {
                    required: true

                }
            },
            messages: {
                sort: {
                    required: "请填写信息"

                }

            },
            highlight: function (e) {
                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            }
//            errorPlacement: function (error, element) {
//                error.insertAfter(element.parent());
//            }
        })

    }
    var validateVip = function () {
        $('#form-1').validate({
            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                name: {
                    required: true,
                    minlength: 8
                },
                keyWord: {
                    required: true
                }
            },
            messages: {
                name: {
                    required: "请填写信息",
                    minlength: "长度不够"
                },
                keyWord: "请填写信息"
            },
            highlight: function (e) {
                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        })
    }
    var valdateVipManage = function () {
        $('#form-1').validate({
            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                pwd: {
                    required: true
                },
                money: {
                    required: true
                }
            },
            messages: {
                pwd: {
                    required: "请填写信息"
                },
                money: "请填写信息"
            },
            highlight: function (e) {
                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            },
            submitHandler: function (form) {

                //form.submit();
                toastr.options = {
                    "closeButton": true,
                    "debug": false,
                    "positionClass": "toast-top-right",
                    "onclick": null,
                    "showDuration": "500",
                    "hideDuration": "500",
                    "timeOut": "10000",
                    "extendedTimeOut": "1000",
                    "showEasing": "linear",
                    "hideEasing": "linear",
                    "showMethod": "slideDown",
                    "hideMethod": "slideUp"
                }
                toastr['success']("恭喜！您输入的数据已保存成功。");
                $('#' + form.id).parents('.modal').modal('hide');


            }
        });
        $('#form-2').validate({
            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                pwd: {
                    required: true
                },
                points: {
                    required: true
                }
            },
            messages: {
                pwd: {
                    required: "请填写信息"
                },
                points: "请填写信息"
            },
            highlight: function (e) {
                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        });
        $('#form-3').validate({
            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                pwd: {
                    required: true
                }
            },
            messages: {
                pwd: {
                    required: "请填写信息"
                }
            },
            highlight: function (e) {
                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        })

    };
    var valdateVipLevel = function () {
        $('#form-1').validate({
            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                name: {
                    required: true
                },
                define: {
                    required: true
                },
                score: {
                    required: true,
                    number: true
                }
            },

            highlight: function (e) {
                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        });

    }
    var valdateVipRights = function () {
        $('#form-1').validate({
            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                name: {
                    required: true
                },
                score: {
                    required: true,
                    number: true
                },
                times: {
                    required: true,
                    number: true
                },
                'date-range-picker': {
                    required: true
                }
            },

            highlight: function (e) {
                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        });
    }
    var validateVipPoint = function () {
        $('#form-1').validate({
            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                money: {
                    required: true,
                    number: true
                },
                points: {
                    required: true,
                    number: true
                }

            },
            messages: {
                money: {
                    required: "请填写消费金额"
                },
                points: {

                    required: "请填写获赠积分"
                }

            },

            highlight: function (e) {
                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        });


        $('#form-2').validate({
            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                money: {
                    required: true,
                    number: true
                },
                points: {
                    required: true,
                    number: true
                }

            },
            messages: {
                money: {
                    required: "请填写消费金额"
                },
                points: {

                    required: "请填写获赠积分"
                }

            },

            highlight: function (e) {
                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        });

    }

    var validateVipMarketing = function () {
        $('#form-1').validate({
            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                times: {
                    required: true,
                    number: true
                },
                points: {
                    required: true,
                    number: true
                },
                'date-range-picker': {
                    required: true
                }

            },
            messages: {
                money: {
                    required: "请填写消费金额"
                },
                points: {

                    required: "请填写获赠积分"
                }

            },

            highlight: function (e) {
                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        });
        $('#form-2').validate({
            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                times: {
                    required: true,
                    number: true
                },
                points: {
                    required: true,
                    number: true
                },
                'date-range-picker': {
                    required: true
                }

            },
            messages: {
                money: {
                    required: "请填写消费金额"
                },
                points: {

                    required: "请填写获赠积分"
                }

            },

            highlight: function (e) {
                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        });
        $('#form-3').validate({
            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                name: {
                    required: true

                },
                content: {
                    required: true

                }

            },

            highlight: function (e) {
                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        });
    };
    var validateVipMessages = function () {
        $('#form-1').validate({
            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                title: {
                    required: true

                },
                content: {
                    required: true
                }

            },
            highlight: function (e) {
                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        });


    };

    var validateVipPwd = function () {

        $('#form-1').validate({
            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                oldPwd: {
                    required: true

                },
                newPwd: {
                    required: true

                },
                confirmPwd: {
                    required: true,
                    equalTo: '#newPwd'
                }

            },
            messages: {

                confirmPwd: {
                    equalTo: "密码输入不一致，请确认"

                }

            },

            highlight: function (e) {
                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        });
        $('#form-2').validate({
            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                value: {
                    required: true
                }
            },

            highlight: function (e) {
                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        });


    };

    var validateBsReply = function () {
        $('#form-1').validate({
            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                keyWord: {
                    required: true
                }
            },

            highlight: function (e) {
                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        });

    }

    var validateActCoupon = function () {
        $('#form-1').validate({
            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                name: {
                    required: true
                },
                keyWord: {
                    required: true
                },
                title: {
                    required: true
                },
                summary: {
                    required: true
                },
                info: {
                    required: true
                },
                'date-picker': {
                    required: true
                },
                'date-range-picker': {
                    required: true
                },
                replyKeyword: {
                    required: true
                },
                couponsNumber: {
                    required: true
                },
                allowsNumber: {
                    required: true
                },
                overFlowWaring: {
                    required: true
                }
            },

            highlight: function (e) {
                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        });

        $('#form-2').validate({

            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                title: {
                    required: true
                },
                summary: {
                    required: true
                },
                content: {
                    required: true
                }

            },
            highlight: function (e) {
                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        });

    }

    var validateActScratch = function () {
        $('#form-1').validate({
            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                name: {
                    required: true
                },
                keyWord: {
                    required: true
                },
                title: {
                    required: true
                },
                summary: {
                    required: true
                },
                info: {
                    required: true
                },
                'date-picker': {
                    required: true
                },
                'date-range-picker': {
                    required: true
                },
                replyKeyword: {
                    required: true
                },
                couponsNumber: {
                    required: true
                },
                allowsNumber: {
                    required: true
                },
                overFlowWaring: {
                    required: true
                }
            },

            highlight: function (e) {
                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        });

        $('#form-2').validate({

            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                title: {
                    required: true
                },
                summary: {
                    required: true
                },
                content: {
                    required: true
                }

            },
            highlight: function (e) {
                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        });

    }

    var validateActFight = function () {

        $('#form-1').validate({
            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                name: {
                    required: true
                },
                keyWord: {
                    required: true
                },
                title: {
                    required: true
                },
                summary: {
                    required: true
                },
                info: {
                    required: true
                },
                'date-picker': {
                    required: true
                },
                'date-range-picker': {
                    required: true
                },
                replyKeyword: {
                    required: true
                },
                couponsNumber: {
                    required: true
                },
                allowsNumber: {
                    required: true
                },
                overFlowWaring: {
                    required: true
                }
            },

            highlight: function (e) {
                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        });

        $('#form-2').validate({

            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                title: {
                    required: true
                },
                summary: {
                    required: true
                },
                content: {
                    required: true
                }

            },
            highlight: function (e) {
                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        });

        $('#form-3').validate({

            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                title: {
                    required: true,
                    maxlength: 60
                },
                optionA: {
                    required: true,
                    maxlength: 16
                },
                optionB: {
                    required: true,
                    maxlength: 16
                },
                optionC: {
                    required: true,
                    maxlength: 16
                },
                optionD: {
                    required: true,
                    maxlength: 16
                }

            },
            highlight: function (e) {
                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            }

        })
    }


    var validateActGoldEgg = function () {
        $('#form-1').validate({
            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                name: {
                    required: true
                },
                keyWord: {
                    required: true
                },
                title: {
                    required: true
                },
                summary: {
                    required: true
                },
                info: {
                    required: true
                },
                'date-picker': {
                    required: true
                },
                'date-range-picker': {
                    required: true
                },
                replyKeyword: {
                    required: true
                },
                couponsNumber: {
                    required: true
                },
                allowsNumber: {
                    required: true
                },
                overFlowWaring: {
                    required: true
                }
            },

            highlight: function (e) {
                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        });

        $('#form-2').validate({

            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                title: {
                    required: true
                },
                summary: {
                    required: true
                },
                content: {
                    required: true
                }

            },
            highlight: function (e) {
                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        });

    }

    var validateActTiger = function () {
        $('#form-1').validate({
            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                name: {
                    required: true
                },
                keyWord: {
                    required: true
                },
                title: {
                    required: true
                },
                summary: {
                    required: true
                },
                info: {
                    required: true
                },
                'date-picker': {
                    required: true
                },
                'date-range-picker': {
                    required: true
                },
                replyKeyword: {
                    required: true
                },
                couponsNumber: {
                    required: true
                },
                allowsNumber: {
                    required: true
                },
                overFlowWaring: {
                    required: true
                }
            },

            highlight: function (e) {
                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        });

        $('#form-2').validate({

            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                title: {
                    required: true
                },
                summary: {
                    required: true
                },
                content: {
                    required: true
                }

            },
            highlight: function (e) {
                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        });

    }
    var validateBusinessGate = function () {
        $('#form-1').validate({
            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                name: {
                    required: true
                },
                replyKeywords: {
                    required: true
                },
                title: {
                    required: true
                }
            },

            highlight: function (e) {
                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        });
        $('#form-2').validate({
            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                name: {
                    required: true
                },
                address: {
                    required: true
                },
                tel: {
                    required: true
                }
            },

            highlight: function (e) {
                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        });

        $('#form-3').validate({
            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                name: {
                    required: true
                },
                address: {
                    required: true
                },
                tel: {
                    required: true
                }
            },

            highlight: function (e) {
                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        });


    }


    var validateBusinessApply = function () {
        $('#form-1').validate({
            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                replyKeywords: {
                    required: true
                },
                title: {
                    required: true
                }
            },

            highlight: function (e) {
                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        });

    }

    var validateBusinessVote = function () {
        $('#form-1').validate({
            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                replyKeywords: {
                    required: true
                },
                title: {
                    required: true
                }
            },

            highlight: function (e) {
                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        });

        $('#form-2').validate({
            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                option1: {
                    required: true
                },
                option2: {
                    required: true
                }
            },

            highlight: function (e) {
                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        });
        $('#form-3').validate({
            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                option1: {
                    required: true
                },
                option2: {
                    required: true
                }
            },

            highlight: function (e) {
                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        });

    }

    var validateBusinessResearch = function () {
        $('#form-1').validate({
            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                replyKeywords: {
                    required: true
                },
                title: {
                    required: true
                }
            },

            highlight: function (e) {
                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        });
        $('#form-2').validate({
            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                name: {
                    required: true
                },
                optionA: {
                    required: true
                },
                optionB: {
                    required: true
                }
            },

            highlight: function (e) {
                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        });
        $('#form-3').validate({
            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                name: {
                    required: true
                },
                optionA: {
                    required: true
                },
                optionB: {
                    required: true
                }
            },

            highlight: function (e) {
                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        });


    }
    var validateBusinessGrouponHandler = function () {
        $('#form-1').validate({
            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                activeName: {
                    required: true
                },
                goodsName: {
                    required: true
                },
                SNCode: {
                    required: true
                },
                bottomPeoples: {
                    required: true
                },
                buyNumber: {
                    required: true
                },
                preDate: {
                    required: true
                },
                grouponPrice: {
                    required: true
                },
                price: {
                    required: true
                }
            },

            highlight: function (e) {
                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        });
    }

    var validateBusinessGrouponPayHandler = function () {
        $('#form-2').validate({
            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                goodsName: {
                    required: true
                },
                summary: {
                    required: true
                },
                grouponPrice: {
                    required: true
                },
                price: {
                    required: true
                },
                description: {
                    required: true
                },
                explanation: {
                    required: true
                },
                dateRange: {
                    required: true
                },
                tips: {
                    required: true
                }
            },

            highlight: function (e) {
                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        });
        $('#form-3').validate({
            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                goodsName: {
                    required: true
                },
                summary: {
                    required: true
                },
                grouponPrice: {
                    required: true
                },
                price: {
                    required: true
                },
                description: {
                    required: true
                },
                explanation: {
                    required: true
                },
                dateRange: {
                    required: true
                },
                tips: {
                    required: true
                }
            },

            highlight: function (e) {
                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        });

        $('#form-4').validate({
            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                account: {
                    required: true
                },
                id: {
                    required: true
                },
                key: {
                    required: true
                }
            },

            highlight: function (e) {
                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        });

        $('#form-5').validate({
            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                name: {
                    required: true
                },
                sort: {
                    required: true
                }
            },

            highlight: function (e) {
                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        });

    };

    var validateBusinessAlbum = function () {
        $('#form-1').validate({
            errorElement: 'div',
            errorClass: 'help-block',
            rules: {

                replyKeywords: {
                    required: true
                },
                title: {
                    required: true
                }
            },

            highlight: function (e) {
                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        });

    }

    var validateBusinessFeedback = function () {
        $('#form-1').validate({
            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                name: {
                    required: true
                },
                replyKeywords: {
                    required: true
                },
                title: {
                    required: true
                }
            },

            highlight: function (e) {
                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        });

    }
    var validatevtripTicket = function () {
        $('#form-1').validate({
            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                name: {
                    required: true
                },
                price: {
                    required: true
                }
            },

            highlight: function (e) {

                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        });
    };


    var validateRestShop = function () {
        var form1v = $('#form-1').validate({
            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                option_value: {
                    required: true, number: true
//                    remote: {
//                        url: "test.aspx",
//                        dataType: "json",
//                        data: {
//                            username: function () {
//                                console.log($("#number").val())
//                                return $("#number").val();
//                            }
//                        }
//                    }

              },
             amount: {required: true, range:[0.1, 100000]},            },
            messages: {},

            highlight: function (e) {

                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        });
        $('#form-1').closest('.modal').on('hidden.bs.modal', function(){
          form1v.resetForm();
          $('#form-1').find('.form-group').removeClass('has-error');
        })
        var form2v = $('#form-2').validate({
            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                option_value: {
                    required: true, number: true
//                    remote: {
//                        url: "test.aspx",
//                        dataType: "json",
//                        data: {
//                            username: function () {
//                                console.log($("#number").val())
//                                return $("#number").val();
//                            }
//                        }
//                    }

                },
                amount: { required: true, range:[0.1, 100000]}
            },

            messages: {},

            highlight: function (e) {

                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        });
        $('#form-2').closest('.modal').on('hidden.bs.modal', function(){
            form2v.resetForm();
            $('#form-2').find('.form-group').removeClass('has-error');
        })
        var form3v = $('#form-3').validate({
            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                points: { required: true, range:[1, 100000]},
                option_value: {
                    required: true, digits: true
//                    remote: {
//                        url: "test.aspx",
//                        dataType: "json",
//                        data: {
//                            username: function () {
//                                console.log($("#number").val())
//                                return $("#number").val();
//                            }
//                        }
//                    }

                }
            },

            messages: {
                number: {remote: "用户不存在"},
                points: {lgt: '如果减少积分则积分不足,可以正常添加积分'}
            },

            highlight: function (e) {

                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        });
        $('#form-3').closest('.modal').on('hidden.bs.modal', function(){
            form3v.resetForm();
            $('#form-3').find('.form-group').removeClass('has-error');
        })
        var form4v = $('#form-4').validate({
            errorElement: 'div',
            errorClass: 'help-block',
            rules: {
                amount: { required: true, range:[0.1, 100000]},
                option_value: {
                    required: true, number: true

//                    remote: {
//                        url: "test.aspx",
//                        dataType: "json",
//                        data: {
//                            username: function () {
//                                console.log($("#number").val())
//                                return $("#number").val();
//                            }
//                        }
//                    }
                }
            },
            messages: {},

            highlight: function (e) {

                $(e).closest('.form-group').removeClass('has-info').addClass('has-error');
            },
            success: function (e) {
                $(e).closest('.form-group').removeClass('has-error');
                $(e).remove();
            },
            errorPlacement: function (error, element) {
                error.insertAfter(element.parent());
            }
        });
        $('#form-4').closest('.modal').on('hidden.bs.modal', function(){
            form4v.resetForm();
            $('#form-4').find('.form-group').removeClass('has-error');
        })
    };


    return {
        validate_vwebsite: validate_vwebsite,
        validateVwebsiteMenus: validateVwebsiteMenus,
        valdateVip: validateVip,
        valdateVipManage: valdateVipManage,
        valdateVipLevel: valdateVipLevel,
        valdateVipRights: valdateVipRights,
        validateVipPoint: validateVipPoint,
        validateVipMarketing: validateVipMarketing,
        validateVipMessages: validateVipMessages,
        validateVipPwd: validateVipPwd,
        validateBsReply: validateBsReply,
        validateActCoupon: validateActCoupon,
        validateActScratch: validateActScratch,
        validateActFight: validateActFight,
        validateActGoldEgg: validateActGoldEgg,
        validateActTiger: validateActTiger,
        validateBusinessGate: validateBusinessGate,
        validateBusinessApply: validateBusinessApply,
        validateBusinessVote: validateBusinessVote,
        validateBusinessResearch: validateBusinessResearch,
        validateBusinessGroupon: validateBusinessGrouponHandler,
        validateBusinessGrouponPay: validateBusinessGrouponPayHandler,
        validateBusinessAlbum: validateBusinessAlbum,
        validateBusinessFeedback: validateBusinessFeedback,
        validatevtripTicket: validatevtripTicket,
        validateRestShop: validateRestShop

    }
}();