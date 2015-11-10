<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>    
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags"%>

<!DOCTYPE html>
<html ng-app="jakdukApp">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<title>${post.subject} - <spring:message code="board.name.free"/> &middot; <spring:message code="common.jakduk"/></title>
	<link href='https://jakduk.com/board/free/${post.seq}' rel='canonical' />
	
	<jsp:include page="../include/html-header.jsp"></jsp:include>
	
	<script src="<%=request.getContextPath()%>/resources/jquery/dist/jquery.min.js"></script>
	
    <!-- CSS Page Style -->    
	<link rel="stylesheet" href="<%=request.getContextPath()%>/resources/unify/assets/css/pages/blog.css">	
	<link rel="stylesheet" href="<%=request.getContextPath()%>/resources/summernote/dist/summernote.css">
	<link rel="stylesheet" href="<%=request.getContextPath()%>/resources/unify/assets/plugins/ladda-buttons/css/custom-lada-btn.css">
</head>

<body>

<c:set var="summernoteLang" value="en-US"/>

<sec:authorize access="isAnonymous()">
	<c:set var="authRole" value="ANNONYMOUS"/>
</sec:authorize>
<sec:authorize access="hasAnyRole('ROLE_USER_01', 'ROLE_USER_02', 'ROLE_USER_03')">
	<c:set var="authRole" value="USER"/>
	<sec:authentication property="principal.id" var="accountId"/>
</sec:authorize>
<sec:authorize access="hasAnyRole('ROLE_ROOT')">
	<c:set var="authAdminRole" value="ROOT"/>
</sec:authorize>		

<c:url var="listUrl" value="/board/free">
	<c:if test="${!empty listInfo.page}">
		<c:param name="page" value="${listInfo.page}"/>
	</c:if>
	<c:if test="${!empty listInfo.category}">
		<c:param name="category" value="${listInfo.category}"/>
	</c:if>
</c:url>

<c:if test="${!empty prev}">
	<c:url var="prevUrl" value="/board/free/${prev.seq}">
		<c:if test="${!empty listInfo.page}">
			<c:param name="page" value="${listInfo.page}"/>
		</c:if>
		<c:if test="${!empty listInfo.category}">
			<c:param name="category" value="${listInfo.category}"/>
		</c:if>
	</c:url>	
</c:if>

<c:if test="${!empty next}">
	<c:url var="nextUrl" value="/board/free/${next.seq}">
		<c:if test="${!empty listInfo.page}">
			<c:param name="page" value="${listInfo.page}"/>
		</c:if>
		<c:if test="${!empty listInfo.category}">
			<c:param name="category" value="${listInfo.category}"/>
		</c:if>
	</c:url>	
</c:if>

<div class="wrapper">
	<jsp:include page="../include/navigation-header.jsp"/>
	
	<!--=== Breadcrumbs ===-->
	<div class="breadcrumbs">
		<div class="container">
			<h1 class="pull-left"><a href="<c:url value="/board/free/refresh"/>"><spring:message code="board.name.free"/></a></h1>
			<ul class="pull-right breadcrumb">
				<li><a href="<c:url value="/board/free/posts"/>"><spring:message code="board.free.breadcrumbs.posts"/></a></li>
				<li><a href="<c:url value="/board/free/comments"/>"><spring:message code="board.free.breadcrumbs.comments"/></a></li>
			</ul>			
		</div><!--/container-->
	</div><!--/breadcrumbs-->
	<!--=== End Breadcrumbs ===-->		
	
	<!--=== Content Part ===-->
	<div class="container content blog-page blog-item">	
	<div class="margin-bottom-10">
	<button type="button" class="btn-u btn-brd rounded" onclick="location.href='${listUrl}'"><i class="fa fa-list"></i></button>
	
	<c:choose>
		<c:when test="${!empty prevUrl}">
			<button type="button" class="btn-u btn-brd rounded" onclick="location.href='${prevUrl}'"><i class="fa fa-chevron-left"></i></button>		
		</c:when>
		<c:otherwise>
			<button type="button" class="btn-u btn-brd rounded btn-u-default disabled" disabled="disabled"><i class="fa fa-chevron-left text-muted"></i></button>
		</c:otherwise>
	</c:choose>
	<c:choose>
		<c:when test="${!empty nextUrl}">
			<button type="button" class="btn-u btn-brd rounded" onclick="location.href='${nextUrl}'"><i class="fa fa-chevron-right"></i></button>		
		</c:when>
		<c:otherwise>
			<button type="button" class="btn-u btn-brd rounded btn-u-default disabled" disabled="disabled"><i class="fa fa-chevron-right text-muted"></i></button>		
		</c:otherwise>
	</c:choose>	
	
	<c:if test="${authRole != 'ANNONYMOUS' && accountId == post.writer.userId}">
		<button type="button" class="btn-u rounded" onclick="location.href='<c:url value="/board/free/edit/${post.seq}"/>'">
			<i class="fa fa-pencil-square-o"></i> <spring:message code="common.button.edit"/>
		</button>
		<button type="button" class="btn-u btn-u-default rounded" onclick="confirmDelete();">
			<i class="fa fa-trash-o"></i> <spring:message code="common.button.delete"/>
		</button>	
	</c:if>
	
	<c:choose>
		<c:when test="${authAdminRole == 'ROOT' && post.status.notice != 'notice' && post.status.delete != 'delete'}">
			<button type="button" class="btn-u rounded" onclick="location.href='<c:url value="/board/notice/set/${post.seq}"/>'">
				<spring:message code="common.button.set.as.notice"/>
			</button>
		</c:when>
		<c:when test="${authAdminRole == 'ROOT' && post.status.notice == 'notice' && post.status.delete != 'delete'}">
			<button type="button" class="btn-u btn-u-default rounded" onclick="location.href='<c:url value="/board/notice/cancel/${post.seq}"/>'">
				<spring:message code="common.button.cancel.notice"/>
			</button>		
		</c:when>
	</c:choose>
</div>

	<c:choose>	
		<c:when test="${result == 'setNotice'}">
			<div class="contex-bg"><p class="bg-success rounded"><spring:message code="board.msg.set.as.notice"/></p></div>		
		</c:when>	
		<c:when test="${result == 'cancelNotice'}">
			<div class="contex-bg"><p class="bg-success rounded"><spring:message code="board.msg.cancel.notice"/></p></div>
		</c:when>
		<c:when test="${result == 'alreadyNotice'}">
			<div class="contex-bg"><p class="bg-danger rounded"><spring:message code="board.msg.error.already.notice"/></p></div>
		</c:when>
		<c:when test="${result == 'alreadyNotNotice'}">
			<div class="contex-bg"><p class="bg-danger rounded"><spring:message code="board.msg.error.already.not.notice"/></p></div>
		</c:when>		
		<c:when test="${result == 'existComment'}">
			<div class="contex-bg"><p class="bg-danger rounded"><spring:message code="board.msg.error.can.not.delete.post"/></p></div>
		</c:when>
		<c:when test="${result == 'emptyComment'}">
			<div class="contex-bg"><p class="bg-danger rounded"><spring:message code="board.msg.error.can.not.delete.post.except.comment"/></p></div>
		</c:when>
	</c:choose>
	
        <!--Blog Post-->        
    	<div class="blog margin-bottom-20" ng-controller="boardFreeCtrl">
    	<input type="hidden" id="subject" value="${post.subject}">
        	<h2>
        	<small>
				<c:if test="${post.status.device == 'mobile'}"><span aria-hidden="true" class=" icon-screen-smartphone"></span></c:if>
				<c:if test="${post.status.device == 'tablet'}"><span aria-hidden="true" class=" icon-screen-tablet"></span></c:if>
				<c:if test="${galleries != null}"><span aria-hidden="true" class="icon-picture"></span></c:if>
			</small>
				<c:choose>
					<c:when test="${post.status.delete == 'delete'}">
						<spring:message code="board.msg.deleted"/>
					</c:when>
					<c:otherwise>
						${post.subject}
					</c:otherwise>
				</c:choose>
				
	  		<c:if test="${!empty category}"><small><span aria-hidden="true" class="icon-directions"></span><spring:message code="${category.resName}"/></small></c:if>        	
        	</h2>
            <div class="blog-post-tags">
                <ul class="list-unstyled list-inline blog-info">
                    <li><span aria-hidden="true" class="icon-user"></span> ${post.writer.username}</li>
                    <li>{{dateFromObjectId("${post.id}") | date:"${dateTimeFormat.dateTime}"}}</li>
                    <li><span aria-hidden="true" class="icon-eye"></span> ${post.views}</li>
                </ul>                    
            </div>
            
			<c:choose>
				<c:when test="${post.status.delete == 'delete'}">
					<p><spring:message code="board.msg.deleted"/></p>
				</c:when>
				<c:otherwise>
					<p>${post.content}</p>
				</c:otherwise>
			</c:choose>            
			
	<!-- galleries -->			
	<c:if test="${galleries != null}">
	<ul class="list-group">
	  <li class="list-group-item">
	  <strong><spring:message code="board.gallery.list"/></strong>
			<c:forEach items="${galleries}" var="gallery">
				<div>
					<span aria-hidden="true" class="icon-paper-clip"></span>
					<a href="<c:url value="/gallery/view/${gallery.id}"/>">${gallery.name}</a> | 
					<fmt:formatNumber value="${gallery.size/1024}" pattern=".00"/> KB
				</div>
			</c:forEach>    
	  </li>
	</ul>	
	</c:if>				
	
<!-- buttons -->	
<div class="ladda-btn margin-bottom-10">
	<div class="row">
		<div class="col-xs-6">
			<button class="btn-u btn-brd rounded btn-u-blue btn-u-sm ladda-button" type="button"
				ng-click="btnFeeling('like')" ng-init="numberOfLike=${fn:length(post.usersLiking)}"
				ladda="btnLike" data-style="expand-right" data-spinner-color="Gainsboro">
				<i class="fa fa-thumbs-o-up fa-lg"></i>
			   <span ng-hide="likeConn == 'connecting'">{{numberOfLike}}</span>      
			</button>
			<button class="btn-u btn-brd rounded btn-u-red btn-u-sm ladda-button" type="button" 
				ng-click="btnFeeling('dislike')" ng-init="numberOfDislike=${fn:length(post.usersDisliking)}"
				ladda="btnDislike" data-style="expand-right" data-spinner-color="Gainsboro">
				<i class="fa fa-thumbs-o-down fa-lg"></i>
			   <span ng-hide="dislikeConn == 'connecting'">{{numberOfDislike}}</span>      
			</button>
		</div>
		<div class="col-xs-6 text-right">
			<button class="btn-u btn-brd rounded btn-u-sm ladda-button" type="button" ng-click="btnUrlCopy()">
				<i class="icon-link"></i>
			</button>
			<a id="kakao-link-btn" href="javascript:;">
				<img src="<%=request.getContextPath()%>/resources/kakao/icon/kakaolink_btn_small.png" />
			</a>
		</div>		
	</div>
</div>

<div class="alert {{alert.classType}} fade in rounded" ng-show="alert.msg">
	{{alert.msg}} <a class="alert-link" ng-href="{{alert.linkUrl}}" ng-show="alert.linkUrl">{{alert.linkLabel}}</a>
</div>

</div>
<!--End Blog Post-->   	
	
	<hr class="padding-10"/>
	
	<!-- comment -->		
	<div ng-controller="commentCtrl">
	
	<input type="hidden" id="commentCount" value="{{commentCount}}">

<!-- 댓글 목록  -->	
<div class="media margin-bottom-10">
	<h4 id="comments" class="text-primary" infinite-scroll="initComment()" infinite-scroll-disabled="infiniteDisabled">		  
		<spring:message code="board.msg.comment.count" arguments="{{commentCount}}"/>
		<button type="button" class="btn btn-link" ng-click="btnRefreshComment()">
			<i class="fa fa-refresh text-muted" ng-class="{'fa-spin':loadCommentConn == 'connecting'}"></i>
		</button>
	</h4>

	<div class="media-body">
		<div ng-repeat="comment in commentList">
			<h5 class="media-heading">
				<i aria-hidden="true" class="icon-user"></i>{{comment.writer.username}}
				<span>{{dateFromObjectId(comment.id) | date:"${dateTimeFormat.dateTime}"}}</span>
			</h5>    
			<p>
				<span aria-hidden="true" class="icon-screen-smartphone" ng-if="comment.status.device == 'mobile'"></span>
				<span aria-hidden="true" class="icon-screen-tablet" ng-if="comment.status.device == 'tablet'"></span>
				<span ng-bind-html="comment.content"></span>
			</p>
			
			<button type="button" class="btn btn-xs rounded btn-default" ng-click="btnCommentFeeling(comment.id, 'like')">
				<span ng-init="numberOfCommentLike[comment.id]=comment.usersLiking.length">
					<i class="fa fa-thumbs-o-up fa-lg"></i>
					{{numberOfCommentLike[comment.id]}}
				</span>
			</button>
			<button type="button" class="btn btn-xs rounded btn-default" ng-click="btnCommentFeeling(comment.id, 'dislike')">
				<span ng-init="numberOfCommentDislike[comment.id]=comment.usersDisliking.length">
					<i class="fa fa-thumbs-o-down fa-lg"></i>
					{{numberOfCommentDislike[comment.id]}}
				</span>
			</button>							
			<div class="text-danger" ng-show="commentFeelingConn[comment.id]">{{commentFeelingAlert[comment.id]}}</div>							 
		    <hr class="padding-5">
		</div>
		
		<div class="margin-bottom-10" ng-show="commentCount || commentAlert.msg">
			<button type="button" class="btn-u btn-brd rounded btn-block btn-u-dark" 
			ng-click="btnMoreComment()" ng-show="commentCount">
				<spring:message code="common.button.load.comment"/> <i class="fa fa-angle-down"></i>
				<i class="fa fa-circle-o-notch fa-spin" ng-show="loadCommentConn == 'connecting'"></i>
			</button>
		</div>
	
		<div class="contex-bg" ng-show="commentAlert.msg">
			<p class="{{commentAlert.classType}} rounded">{{commentAlert.msg}}</p>
		</div>
	</div>
</div>		
                
<!-- 댓글 남기기 -->                
<div class="post-comment">
	<h4 class="text-primary"><spring:message code="board.comment.leave.comment"/></h4>
	<div class="margin-bottom-10">            
		<summernote config="options" on-focus="focus(evt)" 
		ng-model="summernote.content" ng-init="summernote={content:'♪', seq:'${post.seq}'}"></summernote>
		<span class="{{summernoteAlert.classType}}" ng-show="summernoteAlert.msg">{{summernoteAlert.msg}}</span>
	</div>				  

	<div class="margin-bottom-10">
		<c:choose>
			<c:when test="${authRole == 'ANNONYMOUS'}">
				<button type="button" class="btn-u btn-brd rounded btn-u-default disabled" disabled="disabled">
					<span aria-hidden="true" class="icon-pencil"></span> <spring:message code="common.button.write.comment"/>
				</button>	
			</c:when>
			<c:when test="${authRole == 'USER'}">
				<button type="button" class="btn-u btn-brd rounded btn-u-sm ladda-button" 
				ng-click="btnWriteComment()" 
				ladda="writeComment" data-style="expand-right" data-spinner-color="Gainsboro">
					<span aria-hidden="true" class="icon-pencil"></span> <spring:message code="common.button.write.comment"/>
				</button>				
			</c:when>
		</c:choose>	
		{{summernote.content.length}} / {{boardCommentContentLengthMax}}			          
	</div>
	<div>
		<span class="{{writeCommentAlert.classType}}" ng-show="writeCommentAlert.msg">{{writeCommentAlert.msg}}</span>
	</div>	
</div>                
	
	</div>
	
	<div class="margin-bottom-10">
	<button type="button" class="btn-u btn-brd rounded" onclick="location.href='${listUrl}'"><i class="fa fa-list"></i></button>
	
	<c:choose>
		<c:when test="${!empty prevUrl}">
			<button type="button" class="btn-u btn-brd rounded" onclick="location.href='${prevUrl}'"><i class="fa fa-chevron-left"></i></button>		
		</c:when>
		<c:otherwise>
			<button type="button" class="btn-u btn-brd rounded btn-u-default disabled" disabled="disabled"><i class="fa fa-chevron-left text-muted"></i></button>
		</c:otherwise>
	</c:choose>
	<c:choose>
		<c:when test="${!empty nextUrl}">
			<button type="button" class="btn-u btn-brd rounded" onclick="location.href='${nextUrl}'"><i class="fa fa-chevron-right"></i></button>		
		</c:when>
		<c:otherwise>
			<button type="button" class="btn-u btn-brd rounded btn-u-default disabled" disabled="disabled"><i class="fa fa-chevron-right text-muted"></i></button>		
		</c:otherwise>
	</c:choose>	
	
	<c:if test="${authRole != 'ANNONYMOUS' && accountId == post.writer.userId}">
		<button type="button" class="btn-u rounded" onclick="location.href='<c:url value="/board/free/edit/${post.seq}"/>'">
			<i class="fa fa-pencil-square-o"></i> <spring:message code="common.button.edit"/>
		</button>
		<button type="button" class="btn-u btn-u-default rounded" onclick="confirmDelete();">
			<i class="fa fa-trash-o"></i> <spring:message code="common.button.delete"/>
		</button>	
	</c:if>
	
	<c:choose>
		<c:when test="${authAdminRole == 'ROOT' && post.status.notice != 'notice' && post.status.delete != 'delete'}">
			<button type="button" class="btn-u rounded" onclick="location.href='<c:url value="/board/notice/set/${post.seq}"/>'">
				<spring:message code="common.button.set.as.notice"/>
			</button>
		</c:when>
		<c:when test="${authAdminRole == 'ROOT' && post.status.notice == 'notice' && post.status.delete != 'delete'}">
			<button type="button" class="btn-u btn-u-default rounded" onclick="location.href='<c:url value="/board/notice/cancel/${post.seq}"/>'">
				<spring:message code="common.button.cancel.notice"/>
			</button>		
		</c:when>
	</c:choose>
	</div>
	
	</div>	
	
	<jsp:include page="../include/footer.jsp"/>
</div> <!-- /.container -->

<script src="<%=request.getContextPath()%>/resources/summernote/dist/summernote.min.js"></script>
<script src="<%=request.getContextPath()%>/resources/angular-summernote/dist/angular-summernote.min.js"></script>
<script src="<%=request.getContextPath()%>/resources/ng-infinite-scroller-origin/build/ng-infinite-scroll.min.js"></script>
<script src="<%=request.getContextPath()%>/resources/angular-sanitize/angular-sanitize.min.js"></script>
<c:if test="${fn:contains('ko', pageContext.response.locale.language)}">
	<script src="<%=request.getContextPath()%>/resources/summernote/lang/summernote-ko-KR.js"></script>
	<c:set var="summernoteLang" value="ko-KR"/>
</c:if>
<script src="<%=request.getContextPath()%>/resources/unify/assets/plugins/ladda-buttons/js/spin.min.js"></script>
<script src="<%=request.getContextPath()%>/resources/unify/assets/plugins/ladda-buttons/js/ladda.min.js"></script>
<script src="<%=request.getContextPath()%>/resources/angular-ladda/dist/angular-ladda.min.js"></script>

<script src="<%=request.getContextPath()%>/resources/kakao/js/kakao.min.js"></script>
<script src="<%=request.getContextPath()%>/resources/jakduk/js/jakduk.js"></script>
<script type="text/javascript">

var jakdukApp = angular.module("jakdukApp", ["summernote", "infinite-scroll", "ngSanitize", "angular-ladda"]);

jakdukApp.controller("boardFreeCtrl", function($scope, $http) {
	$scope.alert = {};
	$scope.likeConn = "none";
	$scope.dislikeConn = "none";
	$scope.subject = document.getElementById("subject").value;
	
	angular.element(document).ready(function() {
		
		// 사용할 앱의 Javascript 키를 설정해 주세요.
		Kakao.init('${kakaoKey}');

		var label = $scope.subject + '\r<spring:message code="board.name.free"/> · <spring:message code="common.jakduk"/>';
	    
		var kakaoLinkContent = {};
		kakaoLinkContent.container = '#kakao-link-btn';
		kakaoLinkContent.label = label;
	    
		if (!isEmpty("${galleries}")) {
			kakaoLinkContent.image = {
				src: 'https://jakduk.com/gallery/${galleries[0].id}',
				width: '300',
				height: '200'};	
		}
	    
		kakaoLinkContent.webLink = {
			text: 'https://jakduk.com/board/free/${post.seq}',
			url: 'https://jakduk.com/board/free/${post.seq}'
		};
	    
	    // 카카오톡 링크 버튼을 생성합니다. 처음 한번만 호출하면 됩니다.
		Kakao.Link.createTalkLinkButton(kakaoLinkContent);
		
		App.init();
	});		
	
	$scope.objectIdFromDate = function(date) {
		return Math.floor(date.getTime() / 1000).toString(16) + "0000000000000000";
	};
	
	$scope.dateFromObjectId = function(objectId) {
		return new Date(parseInt(objectId.substring(0, 8), 16) * 1000);
	};
	
	$scope.btnFeeling = function(type) {
		if ("${authRole}" == "ANNONYMOUS") {
			$scope.alert.msg = '<spring:message code="board.msg.need.login.for.feel"/>';
			$scope.alert.linkUrl = "<c:url value='/login'/>";
			$scope.alert.linkLabel = '<spring:message code="common.button.login"/>';
			$scope.alert.classType = "alert-warning";
			return;
		} else if ("${accountId}" == "${post.writer.userId}") {
			$scope.alert.msg = '<spring:message code="board.msg.you.are.writer"/>';
			$scope.alert.classType = "alert-warning";
			return;
		}
		
		var bUrl = '<c:url value="/board/' + type + '/${post.seq}.json"/>';
		
		if ($scope.likeConn == "none" && $scope.dislikeConn == "none") {
			
			var reqPromise = $http.get(bUrl);
			
			if (type == "like") {
				$scope.likeConn = "connecting";
				$scope.btnLike = true;
			} else if (type == "dislike") {
				$scope.dislikeConn = "connecting";
				$scope.btnDislike = true;
			}
			
			reqPromise.success(function(data, status, headers, config) {
				var message = "";
				var link = "";
				var mType = "";
				
				if (data.errorCode == "like") {
					message = '<spring:message code="board.msg.select.like"/>';
					mType = "alert-success";
					$scope.numberOfLike = data.numberOfLike;
				} else if (data.errorCode == "dislike") {
					message = '<spring:message code="board.msg.select.dislike"/>';
					mType = "alert-success";
					$scope.numberOfDislike = data.numberOfDislike;
				} else if (data.errorCode == "already") {
					message = '<spring:message code="board.msg.select.already.like"/>';
					mType = "alert-warning";
				} else if (data.errorCode == "anonymous") {
					message = '<spring:message code="board.msg.need.login.for.feel"/>';
					mType = "alert-warning";
				} else if (data.errorCode == "writer") {
					message = '<spring:message code="board.msg.you.are.writer"/>';
					mType = "alert-warning";
				}
				
				$scope.alert.msg = message;
				$scope.alert.classType = mType;
				
				if (type == "like") {
					$scope.likeConn = "success";
					$scope.btnLike = false;
				} else if (type == "dislike") {
					$scope.dislikeConn = "success";
					$scope.btnDislike = false;
				}
			});
			reqPromise.error(function(data, status, headers, config) {				
				$scope.alert.msg = '<spring:message code="common.msg.error.network.unstable"/>';
				$scope.alert.classType = "alert-danger";
				
				if (type == "like") {
					$scope.likeConn = "none";
					$scope.btnLike = false;
				} else if (type == "dislike") {
					$scope.dislikeConn = "none";
					$scope.btnDislike = false;
				}
			});
		}
	};
	
	$scope.btnUrlCopy = function() {
		var url = "https://jakduk.com/board/free/${post.seq}";
		
		if (window.clipboardData){
		    // IE처리
		    // 클립보드에 문자열 복사
		    window.clipboardData.setData('text', url);
		    
		    // 클립보드의 내용 가져오기
		    // window.clipboardData.getData('Text');
		 
		    // 클립보드의 내용 지우기
		    // window.clipboardData.clearData("Text");
		  }  else {                     
		    // 비IE 처리    
		    window.prompt('<spring:message code="common.msg.copy.to.clipboard"/>', url);  
		  }
	};	
});


jakdukApp.controller("commentCtrl", function($scope, $http) {
	$scope.boardCommentContentLengthMin = Jakduk.BoardCommentContentLengthMin;
	$scope.boardCommentContentLengthMax = Jakduk.BoardCommentContentLengthMax;
	
	$scope.commentList = [];
	$scope.commentAlert = {};
	$scope.summernoteAlert = {};
	$scope.commentFeelingConn = {};
	$scope.commentFeelingAlert = {};
	$scope.numberOfCommentLike = {};
	$scope.numberOfCommentDislike = {};
	$scope.loadCommentConn = "none";
	$scope.writeCommentConn = "none";
	$scope.writeCommentAlert = {};
	$scope.infiniteDisabled = false;
	
	angular.element(document).ready(function() {
	});		

	// summernote config
	$scope.options = {
			height: 0,
			lang : "${summernoteLang}",
			toolbar: [
	      ['font', ['bold']],
	      // ['fontsize', ['fontsize']], // Still buggy
	      ['color', ['color']],
	      ['insert', ['link']],
	      ['help', ['help']]			          
				]};	
	
	$scope.focus = function(e) { 
		if ("${authRole}" == "ANNONYMOUS") {
			if (confirm('<spring:message code="board.msg.need.login.for.write"/>') == true) {
				location.href = "<c:url value='/login'/>";
			}
		}	
	};
	
	if ("${authRole}" == "ANNONYMOUS") {
		$scope.summernoteAlert = {"classType":"text-danger", "msg":'<spring:message code="board.msg.need.login.for.write"/>'};
	}

	// http config
	var headers = {
			"Content-Type" : "application/x-www-form-urlencoded"
	};
	
	var config = {
			headers:headers,
			transformRequest: function(obj) {
		        var str = [];
		        for(var p in obj)
		        str.push(encodeURIComponent(p) + "=" + encodeURIComponent(obj[p]));
		        return str.join("&");
		    }
	};
	
	$scope.objectIdFromDate = function(date) {
		return Math.floor(date.getTime() / 1000).toString(16) + "0000000000000000";
	};
	
	$scope.dateFromObjectId = function(objectId) {
		return new Date(parseInt(objectId.substring(0, 8), 16) * 1000);
	};
	
	$scope.intFromObjectId = function(objectId) {
		return parseInt(objectId.substring(0, 8), 16) * 1000;
	};	
	
	$http.defaults.headers.post["Content-Type"] = "application/x-www-form-urlencoded";
	
	$scope.btnWriteComment = function(status) {
		var bUrl = '<c:url value="/board/free/comment/write"/>';
		
		if ($scope.summernote.content.length < Jakduk.BoardCommentContentLengthMin 
				|| $scope.summernote.content.length > Jakduk.BoardCommentContentLengthMax) {
			$scope.summernoteAlert = {"classType":"text-danger", "msg":'<spring:message code="Size.board.comment.content"/>'};
			return;
		}
		
		if ($scope.writeCommentConn == "none") {
			var reqPromise = $http.post(bUrl, $scope.summernote, config);
			$scope.writeCommentConn = "connecting";
			//$scope.writeCommentAlert = {"classType":"text-info", "msg":'<spring:message code="common.msg.be.cummunicating.server"/>'};
			$scope.writeComment = true;
			
			reqPromise.success(function(data, status, headers, config) {
				$scope.btnMoreComment();
				
				$scope.summernote.content = "♪";
				$scope.commentAlert = {};
				$scope.summernoteAlert = {};
				$scope.writeCommentAlert = {};
				$scope.writeCommentConn = "none";
				$scope.writeComment = false;
			});
			reqPromise.error(function(data, status, headers, config) {
				$scope.writeCommentAlert = {"classType":"text-danger", "msg":'<spring:message code="common.msg.error.network.unstable"/>'};
				$scope.writeCommentConn = "none";		
				$scope.writeComment = false;
			});			
		}
	};
	
	$scope.initComment = function() {
		$scope.loadComments("init", "");
		$scope.infiniteDisabled = true;
	}
	
	$scope.loadComments = function(type, commentId) {
		var bUrl = '<c:url value="/board/free/comment/${post.seq}?commentId=' + commentId + '"/>';
		
		if ($scope.loadCommentConn == "none") {
			var reqPromise = $http.get(bUrl);
			
			$scope.loadCommentConn = "connecting";
			
			reqPromise.success(function(data, status, headers, config) {
				
				$scope.commentCount = data.count;
							
				if (data.comments.length < 1) { // 댓글이 하나도 없을때
					if (type == "init") {					
					} else {
						$scope.commentAlert.msg = '<spring:message code="board.msg.there.is.no.new.comment"/>';
						$scope.commentAlert.classType = "bg-warning";				
					}				
				} else {	// 댓글을 1개 이상 가져왔을 때
					if (type == "init" || type == "btnRefreshComment") {
						$scope.commentList = data.comments;
					} else if (type == "btnMoreComment" || type == "btnWriteComment") {
						$scope.commentList = $scope.commentList.concat(data.comments);
					}
				}
				
				$scope.loadCommentConn = "none";
			});
			reqPromise.error(function(data, status, headers, config) {
				$scope.loadCommentConn = "none";
			});			
		}
	};
	
	$scope.btnMoreComment = function() {
		if ($scope.commentList.length > 0) {
			var lastComment = $scope.commentList[$scope.commentList.length - 1];
			$scope.loadComments("btnMoreComment", lastComment.id);
		} else {
			$scope.loadComments("btnMoreComment", "");			
		}
	};
	
	$scope.btnRefreshComment = function() {
		$scope.commentAlert = {};
		$scope.commentList = [];
		$scope.loadComments("btnRefreshComment", "");
	};
	
	$scope.btnCommentFeeling = function(commentId, status) {
		
		var bUrl = '<c:url value="/board/comment/' + status + '/${post.seq}.json?id=' + commentId + '"/>';
		var conn = $scope.commentFeelingConn[commentId];
		
		if (conn == "none" || conn == null) {
			var reqPromise = $http.get(bUrl);
			
			$scope.commentFeelingConn[commentId] = "loading";
			
			reqPromise.success(function(data, status, headers, config) {
				var message = "";
				
				if (data.errorCode == "like") {
					$scope.numberOfCommentLike[commentId] = data.numberOfLike;
				} else if (data.errorCode == "dislike") {
					$scope.numberOfCommentDislike[commentId] = data.numberOfDislike;
				} else if (data.errorCode == "already") {
					message = '<spring:message code="board.msg.select.already.like"/>';
				} else if (data.errorCode == "anonymous") {
					message = '<spring:message code="board.msg.need.login.for.feel"/>';
				} else if (data.errorCode == "writer") {
					message = '<spring:message code="board.msg.you.are.writer"/>';
				}
				
				$scope.commentFeelingAlert[commentId] = message;
				$scope.commentFeelingConn[commentId] = "ok";
				
			});
			reqPromise.error(function(data, status, headers, config) {
				$scope.commentFeelingConn[commentId] = "none";
				$scope.commentFeelingAlert[commentId] = '<spring:message code="common.msg.error.network.unstable"/>';				
			});
		}
	};
});

function confirmDelete() {
	var commentCount = document.getElementById("commentCount").value;
	
	if (commentCount > 0) {
		if (confirm('<spring:message code="board.msg.confirm.delete.post.except.comment"/>') == true) {
			location.href = '<c:url value="/board/free/delete/${post.seq}?type=postonly"/>';
		}	
	} else {
		if (confirm('<spring:message code="board.msg.confirm.delete.post"/>') == true) {
			location.href = '<c:url value="/board/free/delete/${post.seq}?type=all"/>';
		}
	}
}
</script>

<jsp:include page="../include/body-footer.jsp"/>

</body>
</html>