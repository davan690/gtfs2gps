#' @title Filter GTFS data by shape ids
#' 
#' @description Filter a GTFS data by its shape ids. It also removes the
#' unnecessary trips, stop_times, stops, and routes accordingly.
#' @param gtfs_data A list of data.tables read using gtfs2gps::reag_gtfs().
#' @param shape_ids A vector of shape_ids belonging to the shapes of the
#' gtfs_data data. Note that shape_id might be loaded by gtfs2gps::read_gtfs()
#' as a string or a number, depending on the available values.
#' @export
filter_by_shape_id <- function(gtfs_data, shape_ids){
  gtfs_data$shapes <- subset(gtfs_data$shapes, shape_id %in% shape_ids)
  gtfs_data$trips <- subset(gtfs_data$trips, shape_id %in% shape_ids)
  
  trip_ids <- unique(gtfs_data$trips$trip_id)
  
  gtfs_data$stop_times <- subset(gtfs_data$stop_times, trip_id %in% trip_ids)
  
  if(!is.null(gtfs_data$frequencies))
    gtfs_data$frequencies <- subset(gtfs_data$frequencies, trip_id %in% trip_ids)

  stop_ids <- unique(gtfs_data$stop_times$stop_id)
  
  gtfs_data$stops <- subset(gtfs_data$stops, stop_id %in% stop_ids)
  
  route_ids <- unique(gtfs_data$trips$route_id)
  
  gtfs_data$routes <- subset(gtfs_data$routes, route_id %in% route_ids)

  return(gtfs_data)
}

#' @title Filter GTFS data using valid stop times
#' 
#' @description Filter a GTFS data read using gtfs2gps::read_gtfs(). It removes stop_times
#' with NA values in arrival_time, departure_time, and arrival_time_hms. It also filters
#' stops and routes accordingly.
#' @param gtfs_data A list of data.tables read using gtfs2gps::reag_gtfs().
#' @export
filter_valid_stop_times <- function(gtfs_data){
  gtfs_data$stop_times <- subset(gtfs_data$stop_times, !is.na(arrival_time) & !is.na(departure_time))

  stop_ids <- unique(gtfs_data$stop_times$stop_id)

  gtfs_data$stops <- subset(gtfs_data$stops, stop_id %in% stop_ids)

  route_ids <- unique(gtfs_data$trips$route_id)

  gtfs_data$routes <- subset(gtfs_data$routes, route_id %in% route_ids)

  return(gtfs_data)
}

#' @title Filter GTFS trips operating on week days
#' 
#' @description Filter a GTFS data read using gtfs2gps::read_gtfs(). It removes the
#' trips operating only saturday or sunday.
#' @param gtfs_data A list of data.tables read using gtfs2gps::reag_gtfs().
#' @export
filter_week_days <- function(gtfs_data){
    calendar_temp <- subset(gtfs_data$calendar, monday > 0 | tuesday > 0 | wednesday > 0 | thursday > 0 | friday > 0)
    serviceids <- calendar_temp$service_id
    gtfs_data$trips <- subset(gtfs_data$trips, service_id %in% serviceids)
    gtfs_data$calendar[, sunday := 0]
    gtfs_data$calendar[, saturday := 0]
    return(gtfs_data)
}

#' @title Filter GTFS trips in order to have one trip per shape_id
#' 
#' @description Filter a GTFS data by keeping only one trip per shape_id.
#' It also removes the unnecessary routes accordingly.
#' @param gtfs_data A list of data.tables read using gtfs2gps::reag_gtfs().
#' @export
filter_single_trip <- function(gtfs_data){
  gtfs_data$trips <- gtfs_data$trips[!duplicated(gtfs_data$trips$shape_id), ]

  trip_ids <- unique(gtfs_data$trips$trip_id)

  if(!is.null(gtfs_data$frequencies))
    gtfs_data$frequencies <- subset(gtfs_data$frequencies, trip_id %in% trip_ids)

  route_ids <- unique(gtfs_data$trips$route_id)
  
  gtfs_data$routes <- subset(gtfs_data$routes, route_id %in% route_ids)
  
  return(gtfs_data)
}
